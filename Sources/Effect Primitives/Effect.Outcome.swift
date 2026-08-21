public import Equation_Primitives
public import Hash_Primitives

extension Effect {

    public enum Outcome<Value: ~Copyable, Failure: Swift.Error>: ~Copyable {

        case resumed(Value)

        case threw(Failure)

        case aborted
    }
}

extension Effect.Outcome: Copyable where Value: Copyable {}
extension Effect.Outcome: Sendable where Value: Sendable & ~Copyable, Failure: Sendable {}

extension Effect.Outcome: Equation.`Protocol`
where Value: Equation.`Protocol` & ~Copyable, Failure: Equation.`Protocol` {

    public static func == (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        switch lhs {
        case .resumed(let lv):
            switch rhs {
            case .resumed(let rv): return lv == rv
            case .threw: return false
            case .aborted: return false
            }

        case .threw(let le):
            switch rhs {
            case .resumed: return false
            case .threw(let re): return le == re
            case .aborted: return false
            }

        case .aborted:
            switch rhs {
            case .resumed: return false
            case .threw: return false
            case .aborted: return true
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

extension Effect.Outcome: Swift.Hashable
where Value: Hash.`Protocol` & ~Copyable, Failure: Hash.`Protocol` {}

extension Effect.Outcome where Value: Copyable {

    public init(_ result: Result<Value, Failure>) {
        switch result {
        case .success(let value):
            self = .resumed(value)

        case .failure(let error):
            self = .threw(error)
        }
    }

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

extension Effect.Outcome where Value: Copyable {

    public var value: Value? {
        if case .resumed(let value) = self {
            return value
        }
        return nil
    }

    public var error: Failure? {
        if case .threw(let error) = self {
            return error
        }
        return nil
    }
}

extension Effect.Outcome where Value: ~Copyable {

    public var isAborted: Bool {
        switch self {
        case .aborted: return true
        case .resumed: return false
        case .threw: return false
        }
    }
}
