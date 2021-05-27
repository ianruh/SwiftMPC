import RealModule
import Collections

/// The natural ln function
///
public class Ln: Node, Function {
    public let identifier: String = "ln"
    public let numArguments: Int = 1

    // Store the parameters for the node
    public var argument: Node

    override public var description: String {
        return "ln(\(self.argument))"
    }

    override public var latex: String {
        return "\\ln(\(self.argument.latex))"
    }

    override public var derivatives: Set<Derivative> {
        return self.argument.derivatives
    }

    override public var typeIdentifier: String {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return "naturallogarithm\(hasher.finalize())"
    }

    required public init(_ params: [Node]) {
        self.argument = params[0]
        super.init()
        self.variables = self.argument.variables
        self.parameters = self.argument.parameters
    }

    public convenience init(_ param: Node) {
        self.init([param])
    }

    @inlinable
    override public func evaluate(withValues values: [Node: Double]) throws -> Double {
        let value = try Double.log(self.argument.evaluate(withValues: values))
        // guard !value.isNaN else {
        //     throw SymbolicMathError.undefinedValue("The ln(\(value)) is undefined.")
        // }

        return value
    }

    override internal func equals(_ otherNode: Node) -> Bool {
        if let ln = otherNode as? Ln {
            return self.argument.equals(ln.argument)
        } else {
            return false
        }
    }

    override public func contains<T: Node>(nodeType: T.Type) -> [Id] {
        var ids: [Id] = []
        if(nodeType == Ln.self) {
            ids.append(self.id)
        }
        ids.append(contentsOf: self.argument.contains(nodeType: nodeType))
        return ids
    }

    @discardableResult override public func replace(_ targetNode: Node, with replacement: Node) -> Node {
        if(targetNode == self) {
            return replacement
        } else {
            return Ln(self.argument.replace(targetNode, with: replacement))
        }
    }

    public override func simplify() -> Node {

        if(self.isSimplified) { return self }

        let new = Ln(self.argument.simplify())
        try! new.setVariableOrder(self.orderedVariables)
        new.isSimplified = true
        return new
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine("naturallog")
        hasher.combine(self.argument)
    }

    override public func swiftCode(using representations: Dictionary<Node, String>) throws -> String {
        return "Double.log(\(try self.argument.swiftCode(using: representations)))"
    }
}