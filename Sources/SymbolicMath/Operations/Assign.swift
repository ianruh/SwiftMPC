import Foundation
import Numerics

/// Assign one node to the other.
public class Assign: Node, Operation {
    // Nil means is the lowest possible precedence
    public let precedence: OperationPrecedence = OperationPrecedence(higherThan: nil)
    public let type: OperationType = .infix
    public let associativity: OperationAssociativity = .none
    public let identifier: String = "="
    
    // Store the parameters for the node
    public var left: Node
    public var right: Node
    
    override public var description: String {
        // This is always true
        return "\(self.left)=\(self.right)"
    }
    
    override public var latex: String {
        return "\(self.left.latex)=\(self.right.latex)"
    }
    
    override public var variables: Set<Variable> {
        return self.left.variables + self.right.variables
    }

    override public var derivatives: Set<Derivative> {
        return self.left.derivatives + self.right.derivatives
    }

    override public var typeIdentifier: String {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return "assign\(hasher.finalize())"
    }
    
    required public init(_ params: [Node]) {
        self.left = params[0]
        self.right = params[1]
    }

    override required public init() {
        self.left = Node()
        self.right = Node()
        super.init()
    }
    
    public func factory(_ params: [Node]) -> Node {
        return Self(params)
    }
    
    @inlinable
    override public func evaluate(withValues values: [Node : Double]) throws -> Double {
        throw SymbolicMathError.notApplicable(message: "evaluate isn't applicable to assignment")
    }

    override internal func equals(_ otherNode: Node) -> Bool {
        if let eq = otherNode as? Assign {
            return self.left.equals(eq.left) && self.right.equals(eq.right)
        } else {
            return false
        }
    }

    override public func contains<T: Node>(nodeType: T.Type) -> [Id] {
        var ids: [Id] = []
        if(nodeType == Assign.self) {
            ids.append(self.id)
        }
        ids.append(contentsOf: self.left.contains(nodeType: nodeType))
        ids.append(contentsOf: self.right.contains(nodeType: nodeType))
        return ids
    }

    @discardableResult override public func replace(_ targetNode: Node, with replacement: Node) -> Node {
        if(targetNode == self) {
            return replacement
        } else {
            return Assign(self.left.replace(targetNode, with: replacement), self.right.replace(targetNode, with: replacement))
        }
    }

    public override func simplify() -> Node {
        return Assign(self.left.simplify(), self.right.simplify())
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine("assign")
        hasher.combine(self.left)
        hasher.combine(self.right)
    }
}