extension Effect {

    public enum Perform {}
}

extension Effect.Continuation {

    public static func one<Value, Failure: Swift.Error>(
        _ resume: @escaping @Sendable (sending Result<Value, Failure>) async -> Void
    ) -> One<Value, Failure> {
        One(
            onValue: { value in await resume(.success(value)) },
            onError: { error in await resume(.failure(error)) }
        )
    }

    public static func one<Value: ~Copyable, Failure: Swift.Error>(
        onValue: @escaping @Sendable (consuming sending Value) async -> Void,
        onError: @escaping @Sendable (Failure) async -> Void
    ) -> One<Value, Failure> {
        One(onValue: onValue, onError: onError)
    }

    public static func multi<Value, Failure: Swift.Error>(
        _ resume: @escaping @Sendable (sending Result<Value, Failure>) async -> Void
    ) -> Multi<Value, Failure> {
        Multi(resume)
    }
}
