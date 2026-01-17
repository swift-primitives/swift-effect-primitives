extension Effect.Handler {
    /// Protocol for handlers that can operate synchronously.
    ///
    /// Synchronous handlers don't require `async` context in their
    /// implementation, though they still use the async continuation
    /// interface for consistency.
    ///
    /// ## When to Use
    ///
    /// Use synchronous handlers when:
    /// - The effect can be handled immediately without async work
    /// - You need deterministic, predictable behavior for testing
    /// - Performance is critical and async overhead matters
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct PureRandomHandler: Effect.Handler.Sync {
    ///     typealias Handled = RandomInt
    ///
    ///     let seed: UInt64
    ///
    ///     func handle(
    ///         _ effect: RandomInt,
    ///         continuation: consuming Effect.Continuation.One<Int, Never>
    ///     ) async {
    ///         // Pure deterministic "random" for testing
    ///         let value = Int(seed % UInt64(effect.range.count))
    ///         await continuation.resume(returning: effect.range.lowerBound + value)
    ///     }
    /// }
    /// ```
    public typealias Sync = EffectHandler
}
