# SUPERSEDED — moved to swift-institute

This experiment has moved to:

`/Users/coen/Developer/swift-institute/Experiments/silgen-thunk-noncopyable-sending-capture/`

## Why moved

Per `experiment-process` [EXP-002a]: the bug is general Swift compiler behavior
(SILGen reabstraction-thunk SIGSEGV on composed `~Copyable` + `sending` +
`@Sendable` capture), not a swift-effect-primitives concern. It belongs
alongside `copypropagation-noncopyable-switch-consume` in the institute-wide
experiments corpus, where it is discoverable to other workstreams that may
trip the same composition class.

## Why renamed

The new name (`silgen-thunk-noncopyable-sending-capture`) advertises the
*composition* that triggers the bug — the SIL phase (SILGen reabstraction
thunk) plus the three composing primitives (`~Copyable`, `sending`,
`@Sendable` capture). The old name described only the surface symptom
("Optional capture") and obscured the bug class.

## Cross-references updated

- `swift-effect-primitives/Sources/Effect Primitives/Effect.Continuation.One.swift`
  "Revisit Trigger" doc comment now points at the institute path.
- `swift-primitives/Research/effect-primitives-and-io-algebra-relation.md`
  §"Findings (Modernization)" now points at the institute path.

The 2026-04-17 reflection
(`swift-institute/Research/Reflections/2026-04-17-effect-primitives-ncopyable-widening-silgen-workaround.md`)
preserves the original path as a frozen snapshot of what the L1 agent did.
