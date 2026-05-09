extension Effect.Continuation {
    /// A multi-shot continuation that can be resumed multiple times.
    ///
    /// Multi-shot continuations enable patterns like:
    /// - Backtracking search
    /// - Probabilistic programming
    /// - Non-deterministic computation
    /// - Coroutines that can be forked
    ///
    /// Each resumption creates a new branch of computation.
    /// The continuation can be copied to enable multiple resumptions.
    ///
    /// ```swift
    /// func handle(_ continuation: Multi<Int, Never>) async {
    ///     // Resume with multiple values - each creates a branch
    ///     for i in 0..<3 {
    ///         await continuation.resume(returning: i)
    ///     }
    /// }
    /// ```
    ///
    /// ## Performance
    ///
    /// Multi-shot continuations require copying the entire call stack,
    /// making them significantly slower than one-shot continuations.
    /// Use ``One`` when possible.
    ///
    /// ## Use Cases
    ///
    /// - **Backtracking**: Try multiple paths, backtrack on failure
    /// - **Probabilistic**: Sample from distributions, fork execution
    /// - **Generators**: Yield multiple values from a single call
    /// - **Coroutines**: Fork and join concurrent branches
    public struct Multi<Value, Failure: Swift.Error>: __EffectContinuation, Sendable {
        @usableFromInline
        internal let _resume: @Sendable (sending Result<Value, Failure>) async -> Void

        /// Creates a multi-shot continuation with the given resume closure.
        ///
        /// - Parameter resume: The closure to invoke when resuming.
        @usableFromInline
        internal init(_ resume: @escaping @Sendable (sending Result<Value, Failure>) async -> Void) {
            self._resume = resume
        }

        /// Resume the continuation with a successful value.
        ///
        /// This can be called multiple times to create multiple branches.
        ///
        /// - Parameter value: The value to resume with.
        @inlinable
        public func resume(returning value: sending Value) async {
            await _resume(.success(value))
        }

        /// Resume the continuation with an error.
        ///
        /// This can be called multiple times to create multiple branches.
        ///
        /// - Parameter error: The error to resume with.
        @inlinable
        public func resume(throwing error: Failure) async {
            await _resume(.failure(error))
        }

        /// Resume the continuation with a result.
        ///
        /// This can be called multiple times to create multiple branches.
        ///
        /// - Parameter result: The result to resume with.
        @inlinable
        public func resume(with result: sending Result<Value, Failure>) async {
            await _resume(result)
        }
    }
}

extension Effect.Continuation.Multi where Value == Void {
    /// Resume the continuation with void.
    ///
    /// Convenience method for effects that return `Void`.
    @inlinable
    public func resume() async {
        await _resume(.success(()))
    }
}

extension Effect.Continuation.Multi where Failure == Never {
    /// Resume the continuation with a successful value.
    ///
    /// This overload is provided for infallible continuations where
    /// the error type is `Never`.
    ///
    /// - Parameter value: The value to resume with.
    @inlinable
    public func resume(returning value: sending Value) async {
        await _resume(.success(value))
    }
}

extension Effect.Continuation.Multi where Value == Void, Failure == Never {
    /// Resume the continuation with void.
    ///
    /// Convenience method for infallible effects that return `Void`.
    @inlinable
    public func resume() async {
        await _resume(.success(()))
    }
}
