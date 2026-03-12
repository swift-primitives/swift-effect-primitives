---
name: effect-primitives
description: |
  Algebraic effect primitives for composable side effects.
  ALWAYS apply when working with effect systems.

layer: implementation

requires:
  - primitives

applies_to:
  - swift
  - swift-primitives
  - swift-effect-primitives
---

# Effect Primitives

Algebraic effects for composable side effect handling.

---

## Core Design Decisions

### [EFF-001] Effect Composition

**Statement**: Effects MUST compose algebraically without runtime overhead.

---

## Cross-References

Full analysis: `Research/Algebraic Effects in Swift.md`
