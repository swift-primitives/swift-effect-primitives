public import Dependency_Primitives

extension Effect {

    public struct Context: Sendable {
        private init() {}
    }
}

extension Effect.Context {

    public typealias Key = Dependency.Key

    public typealias Handlers = Dependency.Values
}

extension Effect.Context {

    public static var current: Handlers {
        Dependency.Scope.current
    }
}

extension Effect.Context {

    public static func with<T, E: Swift.Error>(
        _ modify: (inout Handlers) -> Void,
        operation: () throws(E) -> T
    ) throws(E) -> T {
        try Dependency.Scope.with(modify, operation: operation)
    }

    public static func with<T>(
        _ modify: (inout Handlers) -> Void,
        operation: () -> T
    ) -> T {
        Dependency.Scope.with(modify, operation: operation)
    }
}

extension Effect.Context {

    nonisolated(nonsending)
        public static func with<T, E: Swift.Error>(
            _ modify: (inout Handlers) -> Void,
            operation: nonisolated(nonsending) () async throws(E) -> T
        ) async throws(E) -> T
    {
        try await Dependency.Scope.with(modify, operation: operation)
    }

    nonisolated(nonsending)
        public static func with<T>(
            _ modify: (inout Handlers) -> Void,
            operation: nonisolated(nonsending) () async -> T
        ) async -> T
    {
        await Dependency.Scope.with(modify, operation: operation)
    }
}
