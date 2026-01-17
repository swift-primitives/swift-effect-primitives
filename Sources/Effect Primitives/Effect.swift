/// Namespace for algebraic effect primitives.
///
/// Algebraic effects provide a way to define, perform, and handle
/// operations with resumable continuations. This namespace contains
/// the minimal building blocks required.
///
/// ## Core Concepts
///
/// - **Effects** are operations that a computation cannot handle directly
/// - **Perform** suspends the computation and yields to a handler
/// - **Handlers** interpret effects and resume the continuation
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
/// // Perform effects in a handled context
/// try await Effect.Context.with { handlers in
///     handlers[ConsoleHandler.self] = .live
/// } operation: {
///     let line = try await Effect.perform(ReadLine())
///     print("Read: \(line)")
/// }
/// ```
public enum Effect {
    /// Protocol for types representing effect operations.
    ///
    /// Use `Effect.Protocol` to refer to this type.
    public typealias `Protocol` = __EffectProtocol
}
