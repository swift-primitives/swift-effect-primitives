// Protocol declaration lives in __EffectHandler.swift (single-type-per-file).

extension Effect {
    /// Namespace for handler-related types.
    public enum Handler {
        /// Protocol for types that can handle (interpret) effects.
        ///
        /// Use `Effect.Handler.Protocol` to refer to this type.
        public typealias `Protocol` = __EffectHandler
    }
}
