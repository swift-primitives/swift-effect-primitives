public import Equation_Primitives
public import Hash_Primitives

extension Effect {
    /// The outcome of handling an effect.
    ///
    /// When an effect is performed and handled, the outcome captures
    /// what the handler decided to do with the continuation.
    ///
    /// ## Cases
    ///
    /// - `resumed`: The handler resumed with a value
    /// - `threw`: The handler resumed with an error
    /// - `aborted`: The handler did not resume (computation halted)
    ///
    /// ## Usage
    ///
    /// Outcomes are useful for:
    /// - Inspecting how an effect was handled in tests
    /// - Building effect interpreters that collect results
    /// - Debugging effect handling behavior
    ///
    /// ```swift
    /// let outcome: Effect.Outcome<String, MyError> = ...
    /// switch outcome {
    /// case .resumed(let value):
    ///     print("Got value: \(value)")
    /// case .threw(let error):
    ///     print("Got error: \(error)")
    /// case .aborted:
    ///     print("Handler did not resume")
    /// }
    /// ```
    ///
    /// ## Noncopyable Value
    ///
    /// `Value` admits `~Copyable` types so an outcome may carry a linear
    /// resource. `Outcome` becomes `~Copyable` when `Value` is, gaining
    /// conditional `Copyable` and `Sendable` conformances. Equality and
    /// hashing for `~Copyable` `Value` go through the ecosystem's
    /// `Equation.Protocol` and `Hash.Protocol`; the stdlib's
    /// `Swift.Equatable`/`Swift.Hashable` conformances are available
    /// whenever `Value` is `Copyable`.
    public enum Outcome<Value: ~Copyable, Failure: Error>: ~Copyable {
        /// The effect was handled and computation resumed with a value.
        case resumed(Value)

        /// The effect was handled and computation resumed with an error.
        case threw(Failure)

        /// The effect was handled but computation was aborted (not resumed).
        case aborted
    }
}

// MARK: - Conditional Conformances

extension Effect.Outcome: Copyable where Value: Copyable {}
extension Effect.Outcome: Sendable where Value: Sendable & ~Copyable, Failure: Sendable {}

// Copyable Value: stdlib Equatable/Hashable (backward compatible).
extension Effect.Outcome: Equatable where Value: Equatable, Failure: Equatable {}
extension Effect.Outcome: Hashable where Value: Hashable, Failure: Hashable {}

// ~Copyable-compatible equality and hashing via the ecosystem primitives.
extension Effect.Outcome: Equation.`Protocol`
where Value: Equation.`Protocol` & ~Copyable, Failure: Equation.`Protocol` {
    public static func == (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        switch lhs {
        case .resumed(let lv):
            switch rhs {
            case .resumed(let rv): return lv == rv
            case .threw:           return false
            case .aborted:         return false
            }
        case .threw(let le):
            switch rhs {
            case .resumed:         return false
            case .threw(let re):   return le == re
            case .aborted:         return false
            }
        case .aborted:
            switch rhs {
            case .resumed:         return false
            case .threw:           return false
            case .aborted:         return true
            }
        }
    }
}

extension Effect.Outcome: Hash.`Protocol`
where Value: Hash.`Protocol` & ~Copyable, Failure: Hash.`Protocol` {
    public borrowing func hash(into hasher: inout Hasher) {
        switch self {
        case .resumed(let value):
            hasher.combine(0)
            value.hash(into: &hasher)
        case .threw(let error):
            hasher.combine(1)
            error.hash(into: &hasher)
        case .aborted:
            hasher.combine(2)
        }
    }
}

// MARK: - Result Conversion

extension Effect.Outcome where Value: Copyable {
    /// Creates an outcome from a result.
    ///
    /// - Parameter result: The result to convert.
    public init(_ result: Result<Value, Failure>) {
        switch result {
        case .success(let value):
            self = .resumed(value)
        case .failure(let error):
            self = .threw(error)
        }
    }

    /// Converts this outcome to a result, if possible.
    ///
    /// Returns `nil` if the outcome is `.aborted`.
    public var result: Result<Value, Failure>? {
        switch self {
        case .resumed(let value):
            return .success(value)
        case .threw(let error):
            return .failure(error)
        case .aborted:
            return nil
        }
    }
}

// MARK: - Value Access

extension Effect.Outcome where Value: Copyable {
    /// The resumed value, if any.
    public var value: Value? {
        if case .resumed(let value) = self {
            return value
        }
        return nil
    }

    /// The thrown error, if any.
    public var error: Failure? {
        if case .threw(let error) = self {
            return error
        }
        return nil
    }
}

extension Effect.Outcome where Value: ~Copyable {
    /// Whether the outcome is an abort.
    public var isAborted: Bool {
        switch self {
        case .aborted: return true
        case .resumed: return false
        case .threw:   return false
        }
    }
}
