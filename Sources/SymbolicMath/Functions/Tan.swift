import RealModule

public class Tan: Node, Function {
    public let identifier: String = "tan"
    public let numArguments: Int = 1

    // Store the parameters for the node
    public var argument: Node

    override public var description: String {
        return "tan(\(self.argument))"
    }

    override public var latex: String {
        return "\\tan(\(self.argument.latex))"
    }

    override public var variables: Set<Variable> {
        return self.argument.variables
    }

    override public var parameters: Set<Parameter> {
        return self.argument.parameters
    }

    override public var derivatives: Set<Derivative> {
        return self.argument.derivatives
    }

    override public var typeIdentifier: String {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return "tangent\(hasher.finalize())"
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
        return try Double.tan(self.argument.evaluate(withValues: values))
    }

    override internal func equals(_ otherNode: Node) -> Bool {
        if let tan = otherNode as? Tan {
            return self.argument.equals(tan.argument)
        } else {
            return false
        }
    }

    override public func contains<T: Node>(nodeType: T.Type) -> [Id] {
        var ids: [Id] = []
        if(nodeType == Tan.self) {
            ids.append(self.id)
        }
        ids.append(contentsOf: self.argument.contains(nodeType: nodeType))
        return ids
    }

    @discardableResult override public func replace(_ targetNode: Node, with replacement: Node) -> Node {
        if(targetNode == self) {
            return replacement
        } else {
            return Tan(self.argument.replace(targetNode, with: replacement))
        }
    }

    public override func simplify() -> Node {
        return Tan(self.argument.simplify())
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine("tan")
        hasher.combine(self.argument)
    }

    override public func swiftCode(using representations: Dictionary<Node, String>) throws -> String {
        return "Double.tan(\(try self.argument.swiftCode(using: representations)))"
    }
}