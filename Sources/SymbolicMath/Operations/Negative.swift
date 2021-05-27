import Foundation
import Numerics
import Collections

/// A negative number
public class Negative: Node, Operation {

    public static let staticPrecedence: OperationPrecedence = OperationPrecedence(higherThan: Multiply.staticPrecedence)
    public let precedence: OperationPrecedence = Negative.staticPrecedence
    public let type: OperationType = .prefix
    public let associativity: OperationAssociativity = .none
    public let identifier: String = "-"
    
    // Store the parameters for the node
    public var argument: Node
    
    override public var description: String {
        return "-\(self.argument)"
    }
    
    override public var latex: String {
        return "-\(self.argument.latex)"
    }

    override public var derivatives: Set<Derivative> {
        return self.argument.derivatives
    }

    override public var typeIdentifier: String {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return "negative\(hasher.finalize())"
    }
    
    required public init(_ params: [Node]) {
        self.argument = params[0]
        super.init()
        self.variables = self.argument.variables
        self.parameters = self.argument.parameters
    }
    
    public func factory(_ params: [Node]) -> Node {
        return Self(params)
    }
    
    @inlinable
    override public func evaluate(withValues values: [Node : Double]) throws -> Double {
        return try -1*self.argument.evaluate(withValues: values)
    }

    override internal func equals(_ otherNode: Node) -> Bool {
        if let neg = otherNode as? Negative {
            return self.argument.equals(neg.argument)
        } else {
            return false
        }
    }

    override public func contains<T: Node>(nodeType: T.Type) -> [Id] {
        var ids: [Id] = []
        if(nodeType == Negative.self) {
            ids.append(self.id)
        }
        ids.append(contentsOf: self.argument.contains(nodeType: nodeType))
        return ids
    }

    @discardableResult override public func replace(_ targetNode: Node, with replacement: Node) -> Node {
        if(targetNode == self) {
            return replacement
        } else {
            return Negative(self.argument.replace(targetNode, with: replacement))
        }
    }

    public override func simplify() -> Node {
        if(self.isSimplified) { return self }

        let new = Multiply(Number(-1), self.argument.simplify())
        try! new.setVariableOrder(self.orderedVariables)
        new.isSimplified =  true
        return new
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine("negative")
        hasher.combine(self.argument)
    }

    override public func swiftCode(using representations: Dictionary<Node, String>) throws -> String {
        return "-1*(\(try self.argument.swiftCode(using: representations)))"
    }
}