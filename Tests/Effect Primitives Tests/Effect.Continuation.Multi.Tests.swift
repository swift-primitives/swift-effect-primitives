import Testing

@testable import Effect_Primitives

@Suite
struct `Effect.Continuation.Multi Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    @Test
    func `can be resumed multiple times`() async {
        // SAFETY: test-local state captured by closures invoked and awaited sequentially within this single test body.
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
        // SAFETY: test-local state captured by closures invoked and awaited sequentially within this single test body.
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
        // SAFETY: test-local state captured by closures invoked and awaited sequentially within this single test body.
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
        // SAFETY: test-local state captured by closures invoked and awaited sequentially within this single test body.
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
        struct Failure: Swift.Error, Equatable {
            let code: Int
        }

        // SAFETY: test-local state captured by closures invoked and awaited sequentially within this single test body.
        nonisolated(unsafe) var errors: [Failure] = []

        let continuation = Effect.Continuation.multi { (result: Result<Void, Failure>) async in
            if case .failure(let error) = result {
                errors.append(error)
            }
        }

        await continuation.resume(throwing: Failure(code: 1))
        await continuation.resume(throwing: Failure(code: 2))

        #expect(errors == [Failure(code: 1), Failure(code: 2)])
    }
}
