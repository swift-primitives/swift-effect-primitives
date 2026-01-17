extension Effect.Context {
    /// Storage for registered handlers.
    ///
    /// `Handlers` provides type-safe storage for effect handlers,
    /// keyed by ``EffectContextKey`` conforming types. Access handlers using
    /// the subscript with a key type:
    ///
    /// ```swift
    /// let console = handlers[ConsoleHandler.self]
    /// handlers[ConsoleHandler.self] = .mock
    /// ```
    ///
    /// ## Default Values
    ///
    /// When a handler is not explicitly registered, the subscript
    /// returns the key's default value:
    /// - `liveValue` in production contexts
    /// - `testValue` in test contexts
    ///
    /// ## Thread Safety
    ///
    /// `Handlers` is `Sendable` and safe to use across isolation domains.
    /// The storage is copy-on-write and uses value semantics.
    public struct Handlers: Sendable {
        private var storage: [ObjectIdentifier: any Sendable] = [:]
        private var _isTestContext: Bool = false

        /// Creates an empty handlers container.
        public init() {}

        /// Whether this context is configured for testing.
        ///
        /// When `true`, unregistered keys return their `testValue`
        /// instead of `liveValue`.
        public var isTestContext: Bool {
            get { _isTestContext }
            set { _isTestContext = newValue }
        }

        /// Access a handler by its key type.
        ///
        /// - Parameter key: The key type to look up.
        /// - Returns: The registered handler, or the default value if not registered.
        public subscript<K: EffectContextKey>(key: K.Type) -> K.Value {
            get {
                if let value = storage[ObjectIdentifier(key)] as? K.Value {
                    return value
                }
                return _isTestContext ? K.testValue : K.liveValue
            }
            set {
                storage[ObjectIdentifier(key)] = newValue
            }
        }
    }
}

// MARK: - Test Context Configuration

extension Effect.Context.Handlers {
    /// Creates a handlers container configured for testing.
    ///
    /// Handlers created with this method will return `testValue`
    /// for unregistered keys instead of `liveValue`.
    ///
    /// ```swift
    /// var handlers = Effect.Context.Handlers.forTesting()
    /// // handlers[SomeKey.self] returns SomeKey.testValue
    /// ```
    public static func forTesting() -> Self {
        var handlers = Self()
        handlers._isTestContext = true
        return handlers
    }
}
