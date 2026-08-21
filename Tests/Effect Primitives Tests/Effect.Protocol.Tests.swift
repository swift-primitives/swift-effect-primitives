import Testing

@testable import Effect_Primitives

private struct SimpleEffect: Effect.`Protocol` {
}

extension SimpleEffect {
    typealias Value = String
    typealias Failure = Never
}

private struct EffectWithArguments: Effect.`Protocol` {
    let x: Int
    let y: Int
}

extension EffectWithArguments {
    typealias Arguments = (x: Int, y: Int)
    typealias Value = Int
    typealias Failure = Never

    var arguments: (x: Int, y: Int) { (x, y) }
}

private struct FallibleEffect: Effect.`Protocol` {
}

extension FallibleEffect {
    typealias Value = String

    struct Failure: Swift.Error, Equatable {
        let reason: String
    }
}

@Suite
struct `Effect.Protocol Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    @Test
    func `simple effect with void arguments`() {
        let effect = SimpleEffect()

        let args: Void = effect.arguments
        _ = args
    }

    @Test
    func `effect with custom arguments`() {
        let effect = EffectWithArguments(x: 10, y: 20)

        #expect(effect.arguments.x == 10)
        #expect(effect.arguments.y == 20)
    }

    @Test
    func `effect with typed failure`() {

        let _: FallibleEffect.Failure.Type = FallibleEffect.Failure.self
        let error = FallibleEffect.Failure(reason: "test")
        #expect(error.reason == "test")
    }

    @Test
    func `effect is Sendable`() {

        func requiresSendable<T: Sendable>(_: T.Type) {}
        requiresSendable(SimpleEffect.self)
        requiresSendable(EffectWithArguments.self)
        requiresSendable(FallibleEffect.self)
    }
}
