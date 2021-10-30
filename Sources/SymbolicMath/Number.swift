// Created 2020 github @ianruh

public class Number: Node, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    public typealias IntegerLiteralType = Int
    public typealias FloatLiteralType = Double

    public var value: Double

    override public var description: String {
        return "\(self.value)"
    }

    override public var derivatives: Set<Derivative> {
        return []
    }

    override public var typeIdentifier: String {
        return "\(self.value)"
    }

    override public var latex: String {
        return "\(self.value)"
    }

    override public var variables: Set<Variable> {
        if let variables = self._variables {
            return variables
        } else {
            self._variables = []
            return self._variables!
        }
    }

    override public var parameters: Set<Parameter> {
        if let parameters = self._parameters {
            return parameters
        } else {
            self._parameters = []
            return self._parameters!
        }
    }

    public convenience init(_ num: Int) {
        self.init(Double(num))
    }

    public init(_ num: Double) {
        self.value = num
    }

    public required convenience init(integerLiteral value: Int) {
        self.init(Double(value))
    }

    public required convenience init(floatLiteral value: Double) {
        self.init(value)
    }

    @inlinable
    override public func evaluate(withValues _: [Node: Double]) throws -> Double {
        return self.value
    }

    override internal func equals(_ otherNode: Node) -> Bool {
        if let num = otherNode as? Number {
            return self.value == num.value
        } else {
            return false
        }
    }

    override public func contains<T: Node>(nodeType: T.Type) -> [Id] {
        if nodeType == Number.self {
            return [self.id]
        } else {
            return []
        }
    }

    @discardableResult override public func replace(_ targetNode: Node,
                                                    with replacement: Node) -> Node
    {
        if targetNode == self {
            return replacement
        } else {
            return self
        }
    }

    override public func simplify() -> Node {
        // Don't need to set variable order
        return self
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine("number")
        hasher.combine(self.value)
    }

    override public func swiftCode(using _: [Node: String]) throws -> String {
        return "\(self.value)"
    }
}
