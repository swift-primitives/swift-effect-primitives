/// Marker protocol for types representing effect operations.
///
/// An effect operation is a request to perform some action that
/// the current computation cannot handle directly. Effects are:
/// - **Declared** by conforming to this protocol
/// - **Performed** by yielding to a handler
/// - **Handled** by providing an implementation with access to the continuation
///
/// ## Conformance Requirements
///
/// Conforming types declare their argument and result types:
///
/// ```swift
/// struct ReadLine: Effect.Protocol {
///     typealias Arguments = Void
///     typealias Value = String
///     typealias Failure = Never
/// }
///
/// struct Fetch: Effect.Protocol {
///     typealias Arguments = URL
///     typealias Value = Data
///     typealias Failure = NetworkError
///
///     let url: URL
///     var arguments: URL { url }
/// }
/// ```
///
/// ## Design Rationale
///
/// Effects carry their arguments as instance data rather than method
/// parameters. This enables type-level dispatch and cleaner composition.
///
/// - Note: This protocol is hoisted to module level due to Swift limitations.
///   Use `Effect.Protocol` to refer to this type.
public protocol __EffectProtocol: Sendable {
    /// The arguments provided when performing this effect.
    associatedtype Arguments: Sendable = Void

    /// The success value type returned when the effect is handled.
    associatedtype Value: Sendable

    /// The error type that handling may produce.
    associatedtype Failure: Error = Never

    /// The arguments for this effect instance.
    var arguments: Arguments { get }
}

extension __EffectProtocol where Arguments == Void {
    /// Default implementation providing `()` for effects with no arguments.
    public var arguments: Void { () }
}
