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
    ///     static func perform<E: Effect.Protocol>(
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
    /// struct ReadLine: Effect.Protocol {
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
    /// Creates a one-shot continuation from a `Result`-delivering closure.
    ///
    /// Available when `Value` is `Copyable` because stdlib's
    /// `Result<Value, Failure>` requires a copyable value.
    ///
    /// - Parameter resume: The closure invoked when the handler resumes.
    /// - Returns: A one-shot continuation.
    public static func one<Value, Failure: Swift.Error>(
        _ resume: @escaping @Sendable (sending Result<Value, Failure>) async -> Void
    ) -> One<Value, Failure> {
        One(
            onValue: { value in await resume(.success(value)) },
            onError: { error in await resume(.failure(error)) }
        )
    }

    /// Creates a one-shot continuation from explicit value and error callbacks.
    ///
    /// Handlers invoke exactly one of the two callbacks via
    /// `resume(returning:)` or `resume(throwing:)`. This form supports
    /// `~Copyable` `Value` types where stdlib's `Result` cannot be used.
    ///
    /// - Parameters:
    ///   - onValue: Invoked when the handler resumes with a value.
    ///   - onError: Invoked when the handler resumes with an error.
    /// - Returns: A one-shot continuation.
    public static func one<Value: ~Copyable, Failure: Swift.Error>(
        onValue: @escaping @Sendable (consuming sending Value) async -> Void,
        onError: @escaping @Sendable (Failure) async -> Void
    ) -> One<Value, Failure> {
        One(onValue: onValue, onError: onError)
    }

    /// Creates a multi-shot continuation from a resume closure.
    ///
    /// Multi-shot continuations can be resumed multiple times,
    /// creating multiple branches of computation.
    ///
    /// - Parameter resume: The closure to call when resuming.
    /// - Returns: A multi-shot continuation.
    public static func multi<Value, Failure: Swift.Error>(
        _ resume: @escaping @Sendable (sending Result<Value, Failure>) async -> Void
    ) -> Multi<Value, Failure> {
        Multi(resume)
    }
}
