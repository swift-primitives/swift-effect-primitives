import Testing
@testable import Effect_Primitives

// MARK: - Test Fixtures

private struct CounterKey: EffectContextKey {
    typealias Value = Int
    static var liveValue: Int { 0 }
    static var testValue: Int { 999 }
}

private struct StringKey: EffectContextKey {
    typealias Value = String
    static var liveValue: String { "live" }
    static var testValue: String { "test" }
}

private struct NoTestValueKey: EffectContextKey {
    typealias Value = String
    static var liveValue: String { "default-live" }
    // testValue defaults to liveValue
}

// MARK: - Tests

@Suite("Effect.Context")
struct ContextTests {

    @Test("default handler returns liveValue")
    func defaultLiveValue() {
        let value = Effect.Context.current[CounterKey.self]
        #expect(value == 0)
    }

    @Test("with scope sets handler value")
    func withScopeSetsValue() {
        let result = Effect.Context.with { handlers in
            handlers[CounterKey.self] = 42
        } operation: {
            Effect.Context.current[CounterKey.self]
        }

        #expect(result == 42)
    }

    @Test("nested scopes override correctly")
    func nestedScopes() {
        var values: [Int] = []

        Effect.Context.with { handlers in
            handlers[CounterKey.self] = 1
        } operation: {
            values.append(Effect.Context.current[CounterKey.self])

            Effect.Context.with { handlers in
                handlers[CounterKey.self] = 2
            } operation: {
                values.append(Effect.Context.current[CounterKey.self])
            }

            values.append(Effect.Context.current[CounterKey.self])
        }

        #expect(values == [1, 2, 1])
    }

    @Test("multiple keys in same scope")
    func multipleKeys() {
        let result = Effect.Context.with { handlers in
            handlers[CounterKey.self] = 100
            handlers[StringKey.self] = "custom"
        } operation: {
            (
                counter: Effect.Context.current[CounterKey.self],
                string: Effect.Context.current[StringKey.self]
            )
        }

        #expect(result.counter == 100)
        #expect(result.string == "custom")
    }

    @Test("async with scope works")
    func asyncWithScope() async {
        let result = await Effect.Context.with { handlers in
            handlers[CounterKey.self] = 50
        } operation: {
            await Task.yield()
            return Effect.Context.current[CounterKey.self]
        }

        #expect(result == 50)
    }

    @Test("throwing operation propagates error")
    func throwingOperation() {
        struct TestError: Error {}

        do {
            try Effect.Context.with { _ in } operation: {
                throw TestError()
            }
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is TestError)
        }
    }

    @Test("handlers storage subscript get/set")
    func handlersSubscript() {
        var handlers = Effect.Context.Handlers()

        #expect(handlers[CounterKey.self] == 0) // liveValue

        handlers[CounterKey.self] = 123
        #expect(handlers[CounterKey.self] == 123)

        handlers[CounterKey.self] = 456
        #expect(handlers[CounterKey.self] == 456)
    }
}

@Suite("Effect.Context.Handlers")
struct HandlersTests {

    @Test("isTestContext returns testValue when true")
    func testContextReturnsTestValue() {
        var handlers = Effect.Context.Handlers()
        handlers.isTestContext = true

        #expect(handlers[CounterKey.self] == 999) // testValue
        #expect(handlers[StringKey.self] == "test") // testValue
    }

    @Test("isTestContext false returns liveValue")
    func liveContextReturnsLiveValue() {
        var handlers = Effect.Context.Handlers()
        handlers.isTestContext = false

        #expect(handlers[CounterKey.self] == 0) // liveValue
        #expect(handlers[StringKey.self] == "live") // liveValue
    }

    @Test("forTesting factory sets isTestContext")
    func forTestingFactory() {
        let handlers = Effect.Context.Handlers.forTesting()

        #expect(handlers[CounterKey.self] == 999)
        #expect(handlers.isTestContext)
    }

    @Test("explicit value overrides test/live defaults")
    func explicitValueOverridesDefaults() {
        var handlers = Effect.Context.Handlers.forTesting()
        handlers[CounterKey.self] = 42

        #expect(handlers[CounterKey.self] == 42) // explicit, not testValue
    }

    @Test("testValue defaults to liveValue when not overridden")
    func testValueDefaultsToLive() {
        var handlers = Effect.Context.Handlers.forTesting()

        // NoTestValueKey has no explicit testValue, so it should use liveValue
        #expect(handlers[NoTestValueKey.self] == "default-live")
    }
}
