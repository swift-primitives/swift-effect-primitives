/// Protocol for types that can handle (interpret) effects.
///
/// A handler wraps an operation and intercepts effects performed
/// within it. When an effect is performed:
/// 1. The current continuation is captured
/// 2. Control transfers to the handler
/// 3. The handler can resume, transform, or abort
///
/// Handlers compose via nesting (inner handlers run first):
///
/// ```swift
/// try await Effect.Context.with { handlers in
///     handlers[OuterHandler.self] = outer
/// } operation: {
///     try await Effect.Context.with { handlers in
///         handlers[InnerHandler.self] = inner
///     } operation: {
///         perform(someEffect)  // innerHandler handles first
///     }
/// }
/// ```
///
/// ## Handler Semantics
///
/// Handlers receive ownership of a one-shot continuation and must
/// decide what to do:
///
/// - **Resume normally**: Call `continuation.resume(returning:)`
/// - **Resume with error**: Call `continuation.resume(throwing:)`
/// - **Abort**: Don't resume (continuation is dropped)
/// - **Defer**: Store continuation for later resumption
///
/// ## Type Safety
///
/// Handlers are parameterized by the effect type they handle,
/// ensuring type-safe interpretation of effect arguments and results.
///
/// - Note: This protocol is hoisted to module level due to Swift limitations.
///   Use `Effect.Handler.Protocol` to refer to this type.
public protocol __EffectHandler: Sendable {
    /// The effect type this handler interprets.
    associatedtype Handled: __EffectProtocol

    /// Handle an effect, resuming the continuation.
    ///
    /// - Parameters:
    ///   - effect: The effect being performed
    ///   - continuation: The continuation to resume (consumed)
    func handle(
        _ effect: Handled,
        continuation: consuming Effect.Continuation.One<Handled.Value, Handled.Failure>
    ) async
}

extension Effect {
    /// Namespace for handler-related types.
    public enum Handler {
        /// Protocol for types that can handle (interpret) effects.
        ///
        /// Use `Effect.Handler.Protocol` to refer to this type.
        public typealias `Protocol` = __EffectHandler
    }
}
