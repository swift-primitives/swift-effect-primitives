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
/// ## See Also
///
/// - ``Effect.Continuation.One``: One-shot continuation (move-only, enforced)
/// - ``Effect.Continuation.Multi``: Multi-shot continuation (copyable)
///
/// - Note: This protocol is hoisted to module level due to Swift limitations.
///   Use `Effect.Continuation.Protocol` to refer to this type.
public protocol __EffectContinuation<Value, Failure>: ~Copyable, Sendable {
    /// The success value type this continuation accepts.
    associatedtype Value

    /// The error type this continuation accepts.
    associatedtype Failure: Error

    /// Resume the continuation with a successful value.
    ///
    /// - Parameter value: The value to resume with.
    consuming func resume(returning value: sending Value) async

    /// Resume the continuation with an error.
    ///
    /// - Parameter error: The error to resume with.
    consuming func resume(throwing error: Failure) async

    /// Resume the continuation with a result.
    ///
    /// - Parameter result: The result to resume with.
    consuming func resume(with result: sending Result<Value, Failure>) async
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
