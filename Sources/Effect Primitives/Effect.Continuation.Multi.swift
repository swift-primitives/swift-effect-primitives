extension Effect.Continuation {

    public struct Multi<Value, Failure: Swift.Error>: __EffectContinuation, Sendable {
        @usableFromInline
        internal let _resume: @Sendable (sending Result<Value, Failure>) async -> Void

        @usableFromInline
        internal init(_ resume: @escaping @Sendable (sending Result<Value, Failure>) async -> Void)
        {
            self._resume = resume
        }
    }
}

extension Effect.Continuation.Multi {

    @inlinable
    public func resume(returning value: sending Value) async {
        await _resume(.success(value))
    }

    @inlinable
    public func resume(throwing error: Failure) async {
        await _resume(.failure(error))
    }

    @inlinable
    public func resume(with result: sending Result<Value, Failure>) async {
        await _resume(result)
    }
}

extension Effect.Continuation.Multi where Value == Void {

    @inlinable
    public func resume() async {
        await _resume(.success(()))
    }
}

extension Effect.Continuation.Multi where Failure == Never {

    @inlinable
    public func resume(returning value: sending Value) async {
        await _resume(.success(value))
    }
}

extension Effect.Continuation.Multi where Value == Void, Failure == Never {

    @inlinable
    public func resume() async {
        await _resume(.success(()))
    }
}
