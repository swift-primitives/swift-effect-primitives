// Protocol declaration lives in __EffectContinuation.swift (single-type-per-file).

extension Effect {
    /// Namespace for continuation types.
    public enum Continuation {
        /// Protocol for continuation types.
        ///
        /// Use `Effect.Continuation.Protocol` to refer to this type.
        public typealias `Protocol` = __EffectContinuation
    }
}
