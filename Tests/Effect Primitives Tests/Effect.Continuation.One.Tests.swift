import Testing

@testable import Effect_Primitives

@Suite
struct `Effect.Continuation.One Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    @Test
    func `resume with value completes successfully`() async {
        // SAFETY: test-local state captured by closures invoked and awaited sequentially within this single test body.
        nonisolated(unsafe) var resumed = false
        // SAFETY: test-local state captured by closures invoked and awaited sequentially within this single test body.
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
        // SAFETY: test-local state captured by closures invoked and awaited sequentially within this single test body.
        nonisolated(unsafe) var receivedResult: Result<Int, Never>?

        let continuation = Effect.Continuation.one { (result: Result<Int, Never>) async in
            receivedResult = result
        }

        await continuation.resume(with: .success(42))

        #expect(receivedResult == .success(42))
    }

    @Test
    func `resume with void convenience`() async {
        // SAFETY: test-local state captured by closures invoked and awaited sequentially within this single test body.
        nonisolated(unsafe) var resumed = false

        let continuation: Effect.Continuation.One<Void, Never> = Effect.Continuation.one { _ async in
            resumed = true
        }

        await continuation.resume()

        #expect(resumed)
    }

    @Test
    func `resume with error`() async {
        struct Failure: Swift.Error, Equatable {
            let message: String
        }

        // SAFETY: test-local state captured by closures invoked and awaited sequentially within this single test body.
        nonisolated(unsafe) var receivedError: Failure?

        let continuation = Effect.Continuation.one { (result: Result<String, Failure>) async in
            if case .failure(let error) = result {
                receivedError = error
            }
        }

        await continuation.resume(throwing: Failure(message: "failed"))

        #expect(receivedError == Failure(message: "failed"))
    }
}
