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
    public struct One<Value: Sendable, Failure: Error>: ~Copyable, Sendable {
        @usableFromInline
        internal let _resume: @Sendable (sending Result<Value, Failure>) async -> Void

        /// Creates a one-shot continuation with the given resume closure.
        ///
        /// - Parameter resume: The closure to invoke when resuming.
        @usableFromInline
        internal init(_ resume: @escaping @Sendable (sending Result<Value, Failure>) async -> Void) {
            self._resume = resume
        }

        /// Resume the continuation with a successful value.
        ///
        /// This consumes the continuation, ensuring it cannot be used again.
        ///
        /// - Parameter value: The value to resume with.
        @inlinable
        public consuming func resume(returning value: sending Value) async {
            await _resume(.success(value))
        }

        /// Resume the continuation with an error.
        ///
        /// This consumes the continuation, ensuring it cannot be used again.
        ///
        /// - Parameter error: The error to resume with.
        @inlinable
        public consuming func resume(throwing error: Failure) async {
            await _resume(.failure(error))
        }

        /// Resume the continuation with a result.
        ///
        /// This consumes the continuation, ensuring it cannot be used again.
        ///
        /// - Parameter result: The result to resume with.
        @inlinable
        public consuming func resume(with result: sending Result<Value, Failure>) async {
            await _resume(result)
        }

        /// Extracts the resume closure, consuming this continuation.
        ///
        /// Use this when you need to wrap a continuation in another continuation.
        /// The extracted closure can be captured in a new continuation's closure.
        ///
        /// ```swift
        /// func handle(continuation: consuming One<Int, Never>) async {
        ///     let originalResume = continuation.extract()
        ///     let wrapper = Effect.Continuation.one { result in
        ///         // intercept...
        ///         await originalResume(result)
        ///     }
        ///     await inner.handle(wrapper)
        /// }
        /// ```
        @inlinable
        public consuming func extract() -> @Sendable (sending Result<Value, Failure>) async -> Void {
            _resume
        }
    }
}

extension Effect.Continuation.One where Value == Void {
    /// Resume the continuation with void.
    ///
    /// Convenience method for effects that return `Void`.
    @inlinable
    public consuming func resume() async {
        await _resume(.success(()))
    }
}

extension Effect.Continuation.One where Failure == Never {
    /// Resume the continuation with a successful value.
    ///
    /// This overload is provided for infallible continuations where
    /// the error type is `Never`.
    ///
    /// - Parameter value: The value to resume with.
    @inlinable
    public consuming func resume(returning value: sending Value) async {
        await _resume(.success(value))
    }
}

extension Effect.Continuation.One where Value == Void, Failure == Never {
    /// Resume the continuation with void.
    ///
    /// Convenience method for infallible effects that return `Void`.
    @inlinable
    public consuming func resume() async {
        await _resume(.success(()))
    }
}
