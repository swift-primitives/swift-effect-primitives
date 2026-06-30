# swift-effect-primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Algebraic-effect primitives — effect declarations, resumable continuations, scoped handlers, and handling outcomes — where one-shot continuations are `~Copyable` so exactly-once resumption is checked at compile time.

---

## Key Features

- **Effect declarations** — Conform a type to `Effect.\`Protocol\``; it carries typed `Arguments`, `Value`, and `Failure`, with `Void` arguments and `Never` failure defaulted.
- **One-shot continuations** — `Effect.Continuation.One` is `~Copyable`, so the compiler rejects both a second `resume` and a forgotten one.
- **Multi-shot continuations** — `Effect.Continuation.Multi` resumes repeatedly, supporting backtracking and non-deterministic control flow.
- **Scoped handler registration** — `Effect.Context.with` installs handlers in task-local storage, and nested scopes override outer ones.
- **Linear resources end to end** — Effects, handlers, continuations, and outcomes admit `~Copyable` `Value` and `Arguments`, so owning resources pass through without being copied.
- **Handling outcomes** — `Effect.Outcome` records whether a handler resumed, threw, or aborted, with equality and hashing for `~Copyable` values via the ecosystem's `Equation` and `Hash` protocols.

---

## Quick Start

A handler must resume its continuation exactly once. Because `Effect.Continuation.One` is `~Copyable`, a second `resume` — or a forgotten one — is a compile error instead of a runtime bug:

```swift
import Effect_Primitives

// An operation the surrounding computation cannot satisfy on its own.
struct ReadConfig: Effect.`Protocol` {
    typealias Value = String
}

// A handler interprets the effect and resumes the one-shot continuation.
struct StaticConfig: Effect.Handler.Sync {
    typealias Handled = ReadConfig
    let stored: String

    func handle(
        _ effect: ReadConfig,
        continuation: consuming Effect.Continuation.One<String, Never>
    ) async {
        await continuation.resume(returning: stored)
        // await continuation.resume(returning: stored)  // won't compile: One is ~Copyable
    }
}

let handler = StaticConfig(stored: "production")
let continuation = Effect.Continuation.one { (result: Result<String, Never>) async in
    if case .success(let config) = result { print("config: \(config)") }
}
await handler.handle(ReadConfig(), continuation: continuation)
```

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-effect-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Effect Primitives", package: "swift-effect-primitives")
    ]
)
```

Requires Swift 6.3.1. Platform minimums: macOS 26, iOS 26, tvOS 26, watchOS 26, visionOS 26.

---

## Architecture

Two library products over a single source module.

| Product | When to import |
|---------|----------------|
| `Effect Primitives` | Declaring effects, handlers, continuations, and outcomes in library or application code. |
| `Effect Primitives Test Support` | Test targets exercising effect handling; re-exports the main module alongside `Hash Primitives Test Support`. |

Key types in the `Effect` namespace:

| Type | Purpose |
|------|---------|
| `Effect.\`Protocol\`` | Declares an effect operation with typed `Arguments`, `Value`, and `Failure`. |
| `Effect.Handler.\`Protocol\`` / `Effect.Handler.Sync` | Interprets an effect, receiving the effect and a one-shot continuation. |
| `Effect.Continuation.One` | `~Copyable` one-shot continuation; exactly-once resumption is compiler-enforced. |
| `Effect.Continuation.Multi` | Multi-shot continuation for backtracking and non-deterministic branches. |
| `Effect.Context` | Task-local handler registration via `with(_:operation:)`, with nested-scope override. |
| `Effect.Outcome` | Captures whether a handler resumed, threw, or aborted. |

---

## Community

<!-- BEGIN: discussion -->
*Discussion thread will be created at first public flip.*
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE](LICENSE.md).
