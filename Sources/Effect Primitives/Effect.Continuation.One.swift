extension Effect.Continuation {
    /// A one-shot continuation that MUST be consumed exactly once.
    ///
    /// This continuation uses `~Copyable` to enforce linear usage.
    /// The compiler ensures you cannot accidentally resume twice
    /// or forget to resume.
    ///
    /// ```swift
    /// func handle(_ continuation: consuming One<String, Never>) async {
    ///     await continuation.resume(returning: "Hello")  // Consumes
    ///     // continuation.resume(returning: "World")  // Error: already consumed
    /// }
    /// ```
    ///
    /// ## Performance
    ///
    /// One-shot continuations are more efficient than multi-shot because:
    /// - No stack copying required
    /// - No reference counting overhead
    /// - No runtime checks for double-resume
    ///
    /// ## Safety
    ///
    /// The `~Copyable` constraint provides compile-time guarantees:
    /// - Cannot be resumed twice (would require copying)
    /// - Cannot be accidentally forgotten (ownership tracking)
    /// - Cannot be stored without consuming
    ///
    /// ## Noncopyable Value
    ///
    /// `Value` admits `~Copyable` types so handlers can resume with linear
    /// resources. The value and error paths are stored as two independent
    /// callbacks (`onValue`, `onError`) rather than a single closure over
    /// stdlib `Result` — `Result<Value, Failure>` requires `Value: Copyable`,
    /// and encoding the delivery as a `throws(E) -> sending Value` thunk
    /// that captures a `~Copyable` `Value` runs into task-allocator
    /// ordering issues under `@Sendable` capture. The two-callback form is
    /// the smallest structural change that supports both paths.
    ///
    /// ## Revisit Trigger
    ///
    /// Two-callback storage and the `@Sendable` retention on `_onValue` /
    /// `_onError` are interim, pending a Swift-compiler fix for the
    /// task-allocator / `Optional<~Copyable>` / `@Sendable` capture
    /// interaction that crashes under the thunk form.
    /// Reproducer: `swift-institute/Experiments/silgen-thunk-noncopyable-sending-capture/`.
    /// Revisit thunk form (`() throws(Failure) -> sending Value`) and
    /// `@Sendable` removal ([IMPL-092], research §4.1) when the crash is
    /// resolved upstream.
    public struct One<Value: ~Copyable & Sendable, Failure: Swift.Error>: ~Copyable, Sendable {
        @usableFromInline
        internal let _onValue: @Sendable (consuming sending Value) async -> Void

        @usableFromInline
        internal let _onError: @Sendable (Failure) async -> Void

        /// Creates a one-shot continuation from value and error callbacks.
        ///
        /// Handlers invoke exactly one of the two callbacks via `resume(returning:)`
        /// or `resume(throwing:)`.
        ///
        /// - Parameters:
        ///   - onValue: Invoked when the handler resumes with a value.
        ///   - onError: Invoked when the handler resumes with an error.
        @usableFromInline
        internal init(
            onValue: @escaping @Sendable (consuming sending Value) async -> Void,
            onError: @escaping @Sendable (Failure) async -> Void
        ) {
            self._onValue = onValue
            self._onError = onError
        }

        /// Resume the continuation with a successful value.
        ///
        /// This consumes the continuation, ensuring it cannot be used again.
        ///
        /// - Parameter value: The value to resume with.
        @inlinable
        public consuming func resume(returning value: consuming sending Value) async {
            await _onValue(value)
        }

        /// Resume the continuation with an error.
        ///
        /// This consumes the continuation, ensuring it cannot be used again.
        ///
        /// - Parameter error: The error to resume with.
        @inlinable
        public consuming func resume(throwing error: Failure) async {
            await _onError(error)
        }
    }
}

// MARK: - Copyable Value Conveniences

extension Effect.Continuation.One where Value: Copyable {
    /// Resume the continuation with a result.
    ///
    /// Available when `Value` is `Copyable` because stdlib's
    /// `Result<Value, Failure>` requires a copyable value.
    ///
    /// - Parameter result: The result to resume with.
    @inlinable
    public consuming func resume(with result: sending Result<Value, Failure>) async {
        switch result {
        case .success(let value): await _onValue(value)
        case .failure(let error): await _onError(error)
        }
    }

    /// Wraps this continuation with an intercepting callback.
    ///
    /// The callback is invoked with the result before the original resume.
    /// Returns a new one-shot continuation that must be consumed exactly once.
    ///
    /// Use this to observe or record the result without breaking one-shot semantics.
    ///
    /// - Note: Available when `Value: Copyable` — observation requires that
    ///   the value be inspectable twice (once by the callback, once by the
    ///   original resume). A `~Copyable` value cannot be shared across two
    ///   sinks.
    ///
    /// ```swift
    /// func handle(continuation: consuming One<Int, Never>) async {
    ///     let wrapped = continuation.onResume { result in
    ///         print("Intercepted: \(result)")
    ///     }
    ///     await inner.handle(continuation: wrapped)
    /// }
    /// ```
    @inlinable
    public consuming func onResume(
        _ callback: @escaping @Sendable (sending Result<Value, Failure>) async -> Void
    ) -> Effect.Continuation.One<Value, Failure> where Value: Sendable {
        let onValue = _onValue
        let onError = _onError
        return Effect.Continuation.One(
            onValue: { value in
                await callback(.success(value))
                await onValue(value)
            },
            onError: { error in
                await callback(.failure(error))
                await onError(error)
            }
        )
    }
}

extension Effect.Continuation.One where Value == Void {
    /// Resume the continuation with void.
    ///
    /// Convenience method for effects that return `Void`.
    @inlinable
    public consuming func resume() async {
        await _onValue(())
    }
}

extension Effect.Continuation.One where Value: Copyable, Failure == Never {
    /// Resume the continuation with a successful value.
    ///
    /// This overload is provided for infallible continuations where
    /// the error type is `Never`.
    ///
    /// - Parameter value: The value to resume with.
    @inlinable
    public consuming func resume(returning value: sending Value) async {
        await _onValue(value)
    }
}

extension Effect.Continuation.One where Value == Void, Failure == Never {
    /// Resume the continuation with void.
    ///
    /// Convenience method for infallible effects that return `Void`.
    @inlinable
    public consuming func resume() async {
        await _onValue(())
    }
}
