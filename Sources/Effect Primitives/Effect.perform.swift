// Note: The actual perform implementation requires integration with a runtime layer
// that provides the suspension/resumption coordination. This file defines the shape
// and documents the intended semantics. The swift-effects package builds on these
// primitives to provide the full implementation.

extension Effect {
    /// Marker type for perform operations.
    ///
    /// The actual `perform` functions are defined as extensions on `Effect`
    /// in the runtime layer (swift-effects), which provides:
    /// - Handler dispatch via `Effect.Context`
    /// - Continuation capture and management
    /// - Integration with Swift's async/await
    ///
    /// ## Expected Signature
    ///
    /// The runtime layer provides:
    ///
    /// ```swift
    /// extension Effect {
    ///     static func perform<E: EffectProtocol>(
    ///         _ effect: E
    ///     ) async throws(E.Failure) -> E.Value
    /// }
    /// ```
    ///
    /// ## Semantics
    ///
    /// When `perform` is called:
    /// 1. The current continuation is captured
    /// 2. The handler for `E` is looked up in `Effect.Context.current`
    /// 3. The handler's `handle(_:continuation:)` is called
    /// 4. The caller suspends until the handler resumes
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Define an effect
    /// struct ReadLine: EffectProtocol {
    ///     typealias Value = String
    ///     typealias Failure = Never
    /// }
    ///
    /// // Perform it (with handler in scope)
    /// let line = await Effect.perform(ReadLine())
    /// ```
    public enum Perform {}
}

// MARK: - Continuation Factory

extension Effect.Continuation {
    /// Creates a one-shot continuation from a resume closure.
    ///
    /// This is the primitive for building effect handlers. The runtime
    /// layer uses this to wrap Swift's checked continuations.
    ///
    /// - Parameter resume: The closure to call when resuming.
    /// - Returns: A one-shot continuation.
    public static func one<Value: Sendable, Failure: Error>(
        _ resume: @escaping @Sendable (sending Result<Value, Failure>) async -> Void
    ) -> One<Value, Failure> {
        One(resume)
    }

    /// Creates a multi-shot continuation from a resume closure.
    ///
    /// Multi-shot continuations can be resumed multiple times,
    /// creating multiple branches of computation.
    ///
    /// - Parameter resume: The closure to call when resuming.
    /// - Returns: A multi-shot continuation.
    public static func multi<Value: Sendable, Failure: Error>(
        _ resume: @escaping @Sendable (sending Result<Value, Failure>) async -> Void
    ) -> Multi<Value, Failure> {
        Multi(resume)
    }
}
