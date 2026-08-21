import Testing

@testable import Effect_Primitives

@Suite
struct `Effect.Continuation.One Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    @Test
    func `resume with value completes successfully`() async {

        nonisolated(unsafe) var resumed = false

        nonisolated(unsafe) var receivedValue: String?

        let continuation = Effect.Continuation.one { (result: Result<String, Never>) async in
            unsafe resumed = true
            if case .success(let value) = result {
                unsafe receivedValue = value
            }
        }

        await continuation.resume(returning: "hello")

        #expect(unsafe resumed)
        #expect(unsafe receivedValue == "hello")
    }

    @Test
    func `resume with result success`() async {

        nonisolated(unsafe) var receivedResult: Result<Int, Never>?

        let continuation = Effect.Continuation.one { (result: Result<Int, Never>) async in
            unsafe receivedResult = result
        }

        await continuation.resume(with: .success(42))

        #expect(unsafe receivedResult == .success(42))
    }

    @Test
    func `resume with void convenience`() async {

        nonisolated(unsafe) var resumed = false

        let continuation: Effect.Continuation.One<Void, Never> = Effect.Continuation.one {
            _ async in
            unsafe resumed = true
        }

        await continuation.resume()

        #expect(unsafe resumed)
    }

    @Test
    func `resume with error`() async {
        struct Failure: Swift.Error, Equatable {
            let message: String
        }

        nonisolated(unsafe) var receivedError: Failure?

        let continuation = Effect.Continuation.one { (result: Result<String, Failure>) async in
            if case .failure(let error) = result {
                unsafe receivedError = error
            }
        }

        await continuation.resume(throwing: Failure(message: "failed"))

        #expect(unsafe receivedError == Failure(message: "failed"))
    }
}
