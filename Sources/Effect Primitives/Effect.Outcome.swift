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
    public enum Outcome<Value: Sendable, Failure: Error>: Sendable {
        /// The effect was handled and computation resumed with a value.
        case resumed(Value)

        /// The effect was handled and computation resumed with an error.
        case threw(Failure)

        /// The effect was handled but computation was aborted (not resumed).
        case aborted
    }
}

// MARK: - Result Conversion

extension Effect.Outcome {
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

extension Effect.Outcome {
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

    /// Whether the outcome is an abort.
    public var isAborted: Bool {
        if case .aborted = self {
            return true
        }
        return false
    }
}

// MARK: - Equatable & Hashable

extension Effect.Outcome: Equatable where Value: Equatable, Failure: Equatable {}
extension Effect.Outcome: Hashable where Value: Hashable, Failure: Hashable {}
