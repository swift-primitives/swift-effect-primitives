import Testing

@testable import Effect_Primitives

// MARK: - Test Effects

private struct SimpleEffect: Effect.`Protocol` {
    typealias Value = String
    typealias Failure = Never
}

private struct EffectWithArguments: Effect.`Protocol` {
    typealias Arguments = (x: Int, y: Int)
    typealias Value = Int
    typealias Failure = Never

    let x: Int
    let y: Int

    var arguments: (x: Int, y: Int) { (x, y) }
}

private struct FallibleEffect: Effect.`Protocol` {
    typealias Value = String

    struct Failure: Error, Equatable {
        let reason: String
    }
}

// MARK: - Tests

@Suite("Effect.Protocol")
struct EffectProtocolTests {

    @Test
    func `simple effect with void arguments`() {
        let effect = SimpleEffect()

        // arguments should be () for Void
        let args: Void = effect.arguments
        _ = args  // suppress unused warning
    }

    @Test
    func `effect with custom arguments`() {
        let effect = EffectWithArguments(x: 10, y: 20)

        #expect(effect.arguments.x == 10)
        #expect(effect.arguments.y == 20)
    }

    @Test
    func `effect with typed failure`() {
        // This test verifies the type system works correctly
        // FallibleEffect has a custom Failure type
        let _: FallibleEffect.Failure.Type = FallibleEffect.Failure.self
        let error = FallibleEffect.Failure(reason: "test")
        #expect(error.reason == "test")
    }

    @Test
    func `effect is Sendable`() {
        // Compile-time check - effects must be Sendable
        func requiresSendable<T: Sendable>(_: T.Type) {}
        requiresSendable(SimpleEffect.self)
        requiresSendable(EffectWithArguments.self)
        requiresSendable(FallibleEffect.self)
    }
}
