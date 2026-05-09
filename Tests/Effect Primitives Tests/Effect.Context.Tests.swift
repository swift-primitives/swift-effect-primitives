import Dependency_Primitives
import Testing

@testable import Effect_Primitives

// MARK: - Test Fixtures

private struct CounterKey: Effect.Context.Key {
    typealias Value = Int
    static var liveValue: Int { 0 }
    static var testValue: Int { 999 }
}

private struct StringKey: Effect.Context.Key {
    typealias Value = String
    static var liveValue: String { "live" }
    static var testValue: String { "test" }
}

private struct NoTestValueKey: Effect.Context.Key {
    typealias Value = String
    static var liveValue: String { "default-live" }
    // testValue defaults to liveValue
}

// MARK: - Tests

@Suite("Effect.Context")
struct ContextTests {

    @Test
    func `default handler returns liveValue`() {
        let value = Effect.Context.current[CounterKey.self]
        #expect(value == 0)
    }

    @Test
    func `with scope sets handler value`() {
        let result = Effect.Context.with { handlers in
            handlers[CounterKey.self] = 42
        } operation: {
            Effect.Context.current[CounterKey.self]
        }

        #expect(result == 42)
    }

    @Test
    func `nested scopes override correctly`() {
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

    @Test
    func `multiple keys in same scope`() {
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

    @Test
    func `async with scope works`() async {
        let result = await Effect.Context.with { handlers in
            handlers[CounterKey.self] = 50
        } operation: {
            await Task.yield()
            return Effect.Context.current[CounterKey.self]
        }

        #expect(result == 50)
    }

    @Test
    func `throwing operation propagates error`() {
        struct TestError: Swift.Error {}

        do {
            try Effect.Context.with { _ in
            } operation: {
                throw TestError()
            }
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is TestError)
        }
    }

    @Test
    func `handlers storage subscript get/set`() {
        var handlers = Effect.Context.Handlers()

        #expect(handlers[CounterKey.self] == 0)  // liveValue

        handlers[CounterKey.self] = 123
        #expect(handlers[CounterKey.self] == 123)

        handlers[CounterKey.self] = 456
        #expect(handlers[CounterKey.self] == 456)
    }
}

@Suite("Effect.Context.Handlers")
struct HandlersTests {

    @Test
    func `isTestContext returns testValue when true`() {
        var handlers = Effect.Context.Handlers()
        handlers.isTestContext = true

        #expect(handlers[CounterKey.self] == 999)  // testValue
        #expect(handlers[StringKey.self] == "test")  // testValue
    }

    @Test
    func `isTestContext false returns liveValue`() {
        var handlers = Effect.Context.Handlers()
        handlers.isTestContext = false

        #expect(handlers[CounterKey.self] == 0)  // liveValue
        #expect(handlers[StringKey.self] == "live")  // liveValue
    }

    @Test
    func `forTesting factory sets isTestContext`() {
        let handlers = Effect.Context.Handlers.forTesting()

        #expect(handlers[CounterKey.self] == 999)
        #expect(handlers.isTestContext)
    }

    @Test
    func `explicit value overrides test/live defaults`() {
        var handlers = Effect.Context.Handlers.forTesting()
        handlers[CounterKey.self] = 42

        #expect(handlers[CounterKey.self] == 42)  // explicit, not testValue
    }

    @Test
    func `testValue defaults to liveValue when not overridden`() {
        var handlers = Effect.Context.Handlers.forTesting()

        // NoTestValueKey has no explicit testValue, so it should use liveValue
        #expect(handlers[NoTestValueKey.self] == "default-live")
    }
}
