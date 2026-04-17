/// Protocol for continuation types that can resume suspended computations.
///
/// Continuations represent "the rest of the computation" after an
/// effect is performed. Handlers receive a continuation and can:
/// - Resume with a value (success)
/// - Resume with an error (failure)
/// - Never resume (abort)
/// - Resume multiple times (multi-shot, requires copying)
///
/// ## One-Shot vs Multi-Shot
///
/// One-shot continuations can be resumed at most once. They are
/// more efficient because the stack doesn't need to be copied.
/// Multi-shot continuations can be resumed multiple times, enabling
/// patterns like backtracking or probabilistic programming.
///
/// The `~Copyable` constraint on ``Effect.Continuation.One`` enforces one-shot semantics
/// at compile time, preventing double-resume bugs.
///
/// ## Noncopyable Value Support
///
/// The `Value` associated type admits `~Copyable` types so a handler may
/// resume with a linear resource. `resume(with:)` (which takes a stdlib
/// `Result`) is provided as an extension where `Value: Copyable`; it is
/// intentionally absent from the protocol requirement because stdlib's
/// `Result<Value, Failure>` requires `Value: Copyable`.
///
/// ## See Also
///
/// - ``Effect.Continuation.One``: One-shot continuation (move-only, enforced)
/// - ``Effect.Continuation.Multi``: Multi-shot continuation (copyable)
///
/// - Note: This protocol is hoisted to module level due to Swift limitations.
///   Use `Effect.Continuation.Protocol` to refer to this type.
public protocol __EffectContinuation<Value, Failure>: ~Copyable, Sendable {
    /// The success value type this continuation accepts.
    associatedtype Value: ~Copyable & Sendable

    /// The error type this continuation accepts.
    associatedtype Failure: Error

    /// Resume the continuation with a successful value.
    ///
    /// - Parameter value: The value to resume with.
    consuming func resume(returning value: consuming sending Value) async

    /// Resume the continuation with an error.
    ///
    /// - Parameter error: The error to resume with.
    consuming func resume(throwing error: Failure) async
}

extension Effect {
    /// Namespace for continuation types.
    public enum Continuation {
        /// Protocol for continuation types.
        ///
        /// Use `Effect.Continuation.Protocol` to refer to this type.
        public typealias `Protocol` = __EffectContinuation
    }
}
