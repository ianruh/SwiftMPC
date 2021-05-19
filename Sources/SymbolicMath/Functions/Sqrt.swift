import RealModule

public class Sqrt: Node, Function {
    public let identifier: String = "sqrt"
    public let numArguments: Int = 1

    // Store the parameters for the node
    public var argument: Node

    override public var description: String {
        return "sqrt(\(self.argument))"
    }

    override public var latex: String {
        return "\\sqrt{\(self.argument.latex)}"
    }

    override public var variables: Set<Variable> {
        return self.argument.variables
    }

    override public var derivatives: Set<Derivative> {
        return self.argument.derivatives
    }

    override public var typeIdentifier: String {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return "squareroot\(hasher.finalize())"
    }

    required public init(_ params: [Node]) {
        self.argument = params[0]
    }

    public convenience init(_ param: Node) {
        self.init([param])
    }

    override required public convenience init() {
        self.init([Node()])
    }

    @inlinable
    override public func evaluate(withValues values: [Node: Double]) throws -> Double {
        return try Double.sqrt(self.argument.evaluate(withValues: values))
    }

    override internal func equals(_ otherNode: Node) -> Bool {
        if let sqrt = otherNode as? Sqrt {
            return self.argument.equals(sqrt.argument)
        } else {
            return false
        }
    }

    override public func contains<T: Node>(nodeType: T.Type) -> [Id] {
        var ids: [Id] = []
        if(nodeType == Sqrt.self) {
            ids.append(self.id)
        }
        ids.append(contentsOf: self.argument.contains(nodeType: nodeType))
        return ids
    }

    @discardableResult override public func replace(_ targetNode: Node, with replacement: Node) -> Node {
        if(targetNode == self) {
            return replacement
        } else {
            return Sqrt(self.argument.replace(targetNode, with: replacement))
        }
    }

    public override func simplify() -> Node {
        return Sqrt(self.argument.simplify())
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine("sqrt")
        hasher.combine(self.argument)
    }

    override public func swiftCode(using representations: Dictionary<Variable, String>) throws -> String {
        return "Double.sqrt(\(try self.argument.swiftCode(using: representations)))"
    }
}