import Testing

@testable import Effect_Primitives

@Suite("Effect.Continuation.One")
struct OneContinuationTests {

    @Test
    func `resume with value completes successfully`() async {
        nonisolated(unsafe) var resumed = false
        nonisolated(unsafe) var receivedValue: String?

        let continuation = Effect.Continuation.one { (result: Result<String, Never>) async in
            resumed = true
            if case .success(let value) = result {
                receivedValue = value
            }
        }

        await continuation.resume(returning: "hello")

        #expect(resumed)
        #expect(receivedValue == "hello")
    }

    @Test
    func `resume with result success`() async {
        nonisolated(unsafe) var receivedResult: Result<Int, Never>?

        let continuation = Effect.Continuation.one { (result: Result<Int, Never>) async in
            receivedResult = result
        }

        await continuation.resume(with: .success(42))

        #expect(receivedResult == .success(42))
    }

    @Test
    func `resume with void convenience`() async {
        nonisolated(unsafe) var resumed = false

        let continuation: Effect.Continuation.One<Void, Never> = Effect.Continuation.one { _ async in
            resumed = true
        }

        await continuation.resume()

        #expect(resumed)
    }

    @Test
    func `resume with error`() async {
        struct TestError: Swift.Error, Equatable {
            let message: String
        }

        nonisolated(unsafe) var receivedError: TestError?

        let continuation = Effect.Continuation.one { (result: Result<String, TestError>) async in
            if case .failure(let error) = result {
                receivedError = error
            }
        }

        await continuation.resume(throwing: TestError(message: "failed"))

        #expect(receivedError == TestError(message: "failed"))
    }
}
