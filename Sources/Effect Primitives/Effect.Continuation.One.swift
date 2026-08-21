extension Effect.Continuation {

    public struct One<Value: ~Copyable, Failure: Swift.Error>: ~Copyable, Sendable {
        @usableFromInline
        internal let _onValue: @Sendable (consuming sending Value) async -> Void

        @usableFromInline
        internal let _onError: @Sendable (Failure) async -> Void

        @usableFromInline
        internal init(
            onValue: @escaping @Sendable (consuming sending Value) async -> Void,
            onError: @escaping @Sendable (Failure) async -> Void
        ) {
            self._onValue = onValue
            self._onError = onError
        }
    }
}

extension Effect.Continuation.One where Value: ~Copyable {

    @inlinable
    public consuming func resume(returning value: consuming sending Value) async {
        await _onValue(value)
    }

    @inlinable
    public consuming func resume(throwing error: Failure) async {
        await _onError(error)
    }
}

extension Effect.Continuation.One where Value: Copyable {

    @inlinable
    public consuming func resume(with result: sending Result<Value, Failure>) async {
        switch result {
        case .success(let value): await _onValue(value)
        case .failure(let error): await _onError(error)
        }
    }

    @inlinable
    public consuming func onResume(
        _ callback: @escaping @Sendable (sending Result<Value, Failure>) async -> Void
    ) -> Effect.Continuation.One<Value, Failure> where Value: Sendable {
        let onValue = _onValue
        let onError = _onError
        return Effect.Continuation.One(
            onValue: { value in
                await callback(.success(value))
                await onValue(value)
            },
            onError: { error in
                await callback(.failure(error))
                await onError(error)
            }
        )
    }
}

extension Effect.Continuation.One where Value == Void, Value: ~Copyable {

    @inlinable
    public consuming func resume() async {
        await _onValue(())
    }
}

extension Effect.Continuation.One where Value: Copyable, Failure == Never {

    @inlinable
    public consuming func resume(returning value: sending Value) async {
        await _onValue(value)
    }
}

extension Effect.Continuation.One where Value == Void, Value: ~Copyable, Failure == Never {

    @inlinable
    public consuming func resume() async {
        await _onValue(())
    }
}
