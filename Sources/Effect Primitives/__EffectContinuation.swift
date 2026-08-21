public protocol __EffectContinuation<Value, Failure>: ~Copyable {

    associatedtype Value: ~Copyable

    associatedtype Failure: Swift.Error

    consuming func resume(returning value: consuming sending Value) async

    consuming func resume(throwing error: Failure) async
}
