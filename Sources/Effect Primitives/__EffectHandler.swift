public protocol __EffectHandler: ~Copyable {

    associatedtype Handled: ~Copyable & __EffectProtocol

    func handle(
        _ effect: borrowing Handled,
        continuation: consuming Effect.Continuation.One<Handled.Value, Handled.Failure>
    ) async
}
