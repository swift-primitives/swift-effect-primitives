import Testing
@testable import Effect_Primitives

@Suite("Effect.Outcome")
struct OutcomeTests {

    // MARK: - Basic Cases

    @Test("resumed case stores value")
    func resumedCase() {
        let outcome: Effect.Outcome<String, Never> = .resumed("hello")

        #expect(outcome.value == "hello")
        #expect(outcome.error == nil)
        #expect(!outcome.isAborted)
    }

    @Test("threw case stores error")
    func threwCase() {
        struct TestError: Error, Equatable {
            let code: Int
        }

        let outcome: Effect.Outcome<String, TestError> = .threw(TestError(code: 42))

        #expect(outcome.value == nil)
        #expect(outcome.error == TestError(code: 42))
        #expect(!outcome.isAborted)
    }

    @Test("aborted case")
    func abortedCase() {
        let outcome: Effect.Outcome<String, Never> = .aborted

        #expect(outcome.value == nil)
        #expect(outcome.error == nil)
        #expect(outcome.isAborted)
    }

    // MARK: - Result Conversion

    @Test("init from Result success")
    func initFromResultSuccess() {
        let result: Result<Int, Never> = .success(42)
        let outcome = Effect.Outcome(result)

        #expect(outcome.value == 42)
        if case .resumed(let value) = outcome {
            #expect(value == 42)
        } else {
            Issue.record("Expected resumed case")
        }
    }

    @Test("init from Result failure")
    func initFromResultFailure() {
        struct E: Error, Equatable {}

        let result: Result<Int, E> = .failure(E())
        let outcome = Effect.Outcome(result)

        if case .threw(let error) = outcome {
            #expect(error == E())
        } else {
            Issue.record("Expected threw case")
        }
    }

    @Test("result property for resumed")
    func resultPropertyResumed() {
        let outcome: Effect.Outcome<String, Never> = .resumed("test")

        #expect(outcome.result == .success("test"))
    }

    @Test("result property for threw")
    func resultPropertyThrew() {
        struct E: Error, Equatable {}

        let outcome: Effect.Outcome<String, E> = .threw(E())

        #expect(outcome.result == .failure(E()))
    }

    @Test("result property for aborted returns nil")
    func resultPropertyAborted() {
        let outcome: Effect.Outcome<String, Never> = .aborted

        #expect(outcome.result == nil)
    }

    // MARK: - Equatable

    @Test("equatable for resumed")
    func equatableResumed() {
        let a: Effect.Outcome<Int, Never> = .resumed(1)
        let b: Effect.Outcome<Int, Never> = .resumed(1)
        let c: Effect.Outcome<Int, Never> = .resumed(2)

        #expect(a == b)
        #expect(a != c)
    }

    @Test("equatable for threw")
    func equatableThrew() {
        struct E: Error, Equatable {
            let code: Int
        }

        let a: Effect.Outcome<Int, E> = .threw(E(code: 1))
        let b: Effect.Outcome<Int, E> = .threw(E(code: 1))
        let c: Effect.Outcome<Int, E> = .threw(E(code: 2))

        #expect(a == b)
        #expect(a != c)
    }

    @Test("equatable for aborted")
    func equatableAborted() {
        let a: Effect.Outcome<Int, Never> = .aborted
        let b: Effect.Outcome<Int, Never> = .aborted

        #expect(a == b)
    }

    @Test("different cases not equal")
    func differentCasesNotEqual() {
        struct E: Error, Equatable {}

        let resumed: Effect.Outcome<Int, E> = .resumed(1)
        let threw: Effect.Outcome<Int, E> = .threw(E())
        let aborted: Effect.Outcome<Int, E> = .aborted

        #expect(resumed != threw)
        #expect(resumed != aborted)
        #expect(threw != aborted)
    }

    // MARK: - Hashable

    @Test("hashable consistency")
    func hashableConsistency() {
        let a: Effect.Outcome<Int, Never> = .resumed(42)
        let b: Effect.Outcome<Int, Never> = .resumed(42)

        #expect(a.hashValue == b.hashValue)

        var set: Set<Effect.Outcome<Int, Never>> = []
        set.insert(a)
        #expect(set.contains(b))
    }
}
