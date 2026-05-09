import Testing

@testable import Effect_Primitives

@Suite("Effect.Continuation.Multi")
struct MultiContinuationTests {

    @Test
    func `can be resumed multiple times`() async {
        nonisolated(unsafe) var values: [Int] = []

        let continuation = Effect.Continuation.multi { (result: Result<Int, Never>) async in
            if case .success(let value) = result {
                values.append(value)
            }
        }

        await continuation.resume(returning: 1)
        await continuation.resume(returning: 2)
        await continuation.resume(returning: 3)

        #expect(values == [1, 2, 3])
    }

    @Test
    func `can be copied and resumed from copies`() async {
        nonisolated(unsafe) var count = 0

        let original = Effect.Continuation.multi { (_: Result<Void, Never>) async in
            count += 1
        }

        let copy1 = original
        let copy2 = original

        await original.resume()
        await copy1.resume()
        await copy2.resume()

        #expect(count == 3)
    }

    @Test
    func `resume with result success`() async {
        nonisolated(unsafe) var results: [Result<String, Never>] = []

        let continuation = Effect.Continuation.multi { (result: Result<String, Never>) async in
            results.append(result)
        }

        await continuation.resume(with: .success("a"))
        await continuation.resume(with: .success("b"))

        #expect(results.count == 2)
    }

    @Test
    func `resume with void convenience`() async {
        nonisolated(unsafe) var count = 0

        let continuation: Effect.Continuation.Multi<Void, Never> = Effect.Continuation.multi { _ async in
            count += 1
        }

        await continuation.resume()
        await continuation.resume()

        #expect(count == 2)
    }

    @Test
    func `resume with errors`() async {
        struct TestError: Swift.Error, Equatable {
            let code: Int
        }

        nonisolated(unsafe) var errors: [TestError] = []

        let continuation = Effect.Continuation.multi { (result: Result<Void, TestError>) async in
            if case .failure(let error) = result {
                errors.append(error)
            }
        }

        await continuation.resume(throwing: TestError(code: 1))
        await continuation.resume(throwing: TestError(code: 2))

        #expect(errors == [TestError(code: 1), TestError(code: 2)])
    }
}
