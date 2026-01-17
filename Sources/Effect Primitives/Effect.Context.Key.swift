/// A key for registering handlers in the effect context.
///
/// Conform your handler types to this protocol to enable
/// registration in `Effect.Context`:
///
/// ```swift
/// struct ConsoleHandler: EffectContextKey {
///     typealias Value = ConsoleHandlerImpl
///     static var liveValue: Value { .live }
///     static var testValue: Value { .mock }
/// }
/// ```
///
/// ## Live vs Test Values
///
/// The protocol distinguishes between:
/// - `liveValue`: Used in production code
/// - `testValue`: Used in test contexts (defaults to `liveValue`)
///
/// This enables dependency injection patterns where tests can
/// automatically use mock implementations.
///
/// ## Usage
///
/// Access handlers through the context subscript:
///
/// ```swift
/// let handler = Effect.Context.current[ConsoleHandler.self]
/// ```
///
/// Register handlers in a scope:
///
/// ```swift
/// Effect.Context.with { handlers in
///     handlers[ConsoleHandler.self] = .custom
/// } operation: {
///     // Uses .custom handler here
/// }
/// ```
public protocol EffectContextKey<Value>: Sendable {
    /// The handler type this key provides.
    associatedtype Value: Sendable

    /// The default value for production use.
    static var liveValue: Value { get }

    /// The default value for testing (defaults to liveValue).
    static var testValue: Value { get }
}

extension EffectContextKey {
    /// Default implementation returns the live value.
    ///
    /// Override this in your key type to provide test-specific
    /// implementations (mocks, stubs, spies).
    public static var testValue: Value { liveValue }
}

extension Effect.Context {
    /// Protocol for context keys.
    ///
    /// Use `Effect.Context.Key` to refer to this type.
    public typealias Key = EffectContextKey
}
