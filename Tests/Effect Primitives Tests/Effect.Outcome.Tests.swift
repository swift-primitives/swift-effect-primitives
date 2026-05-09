import Testing

@testable import Effect_Primitives

@Suite("Effect.Outcome")
struct OutcomeTests {

    // MARK: - Basic Cases

    @Test
    func `resumed case stores value`() {
        let outcome: Effect.Outcome<String, Never> = .resumed("hello")

        #expect(outcome.value == "hello")
        #expect(outcome.error == nil)
        #expect(!outcome.isAborted)
    }

    @Test
    func `threw case stores error`() {
        struct TestError: Swift.Error, Equatable {
            let code: Int
        }

        let outcome: Effect.Outcome<String, TestError> = .threw(TestError(code: 42))

        #expect(outcome.value == nil)
        #expect(outcome.error == TestError(code: 42))
        #expect(!outcome.isAborted)
    }

    @Test
    func `aborted case`() {
        let outcome: Effect.Outcome<String, Never> = .aborted

        #expect(outcome.value == nil)
        #expect(outcome.error == nil)
        #expect(outcome.isAborted)
    }

    // MARK: - Result Conversion

    @Test
    func `init from Result success`() {
        let result: Result<Int, Never> = .success(42)
        let outcome = Effect.Outcome(result)

        #expect(outcome.value == 42)
        if case .resumed(let value) = outcome {
            #expect(value == 42)
        } else {
            Issue.record("Expected resumed case")
        }
    }

    @Test
    func `init from Result failure`() {
        struct E: Swift.Error, Equatable {}

        let result: Result<Int, E> = .failure(E())
        let outcome = Effect.Outcome(result)

        if case .threw(let error) = outcome {
            #expect(error == E())
        } else {
            Issue.record("Expected threw case")
        }
    }

    @Test
    func `result property for resumed`() {
        let outcome: Effect.Outcome<String, Never> = .resumed("test")

        #expect(outcome.result == .success("test"))
    }

    @Test
    func `result property for threw`() {
        struct E: Swift.Error, Equatable {}

        let outcome: Effect.Outcome<String, E> = .threw(E())

        #expect(outcome.result == .failure(E()))
    }

    @Test
    func `result property for aborted returns nil`() {
        let outcome: Effect.Outcome<String, Never> = .aborted

        #expect(outcome.result == nil)
    }

    // MARK: - Equatable

    @Test
    func `equatable for resumed`() {
        let a: Effect.Outcome<Int, Never> = .resumed(1)
        let b: Effect.Outcome<Int, Never> = .resumed(1)
        let c: Effect.Outcome<Int, Never> = .resumed(2)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `equatable for threw`() {
        struct E: Swift.Error, Equatable {
            let code: Int
        }

        let a: Effect.Outcome<Int, E> = .threw(E(code: 1))
        let b: Effect.Outcome<Int, E> = .threw(E(code: 1))
        let c: Effect.Outcome<Int, E> = .threw(E(code: 2))

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `equatable for aborted`() {
        let a: Effect.Outcome<Int, Never> = .aborted
        let b: Effect.Outcome<Int, Never> = .aborted

        #expect(a == b)
    }

    @Test
    func `different cases not equal`() {
        struct E: Swift.Error, Equatable {}

        let resumed: Effect.Outcome<Int, E> = .resumed(1)
        let threw: Effect.Outcome<Int, E> = .threw(E())
        let aborted: Effect.Outcome<Int, E> = .aborted

        #expect(resumed != threw)
        #expect(resumed != aborted)
        #expect(threw != aborted)
    }

    // MARK: - Hashable

    @Test
    func `hashable consistency`() {
        let a: Effect.Outcome<Int, Never> = .resumed(42)
        let b: Effect.Outcome<Int, Never> = .resumed(42)

        #expect(a.hashValue == b.hashValue)

        var set: Set<Effect.Outcome<Int, Never>> = []
        set.insert(a)
        #expect(set.contains(b))
    }
}
