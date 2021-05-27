import Foundation
import Numerics
import Collections

/// Assign one node to the other.
public class Assign: Node, Operation {
    // Nil means is the lowest possible precedence
    public static let staticPrecedence: OperationPrecedence = OperationPrecedence(higherThan: nil)
    public let precedence: OperationPrecedence = Assign.staticPrecedence
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
        if let variables = self._variables {
            return variables
        } else {
            self._variables = self.left.variables + self.right.variables
            return self._variables!
        }
    }

    override public var parameters: Set<Parameter> {
        if let parameters = self._parameters {
            return parameters
        } else {
            self._parameters = self.left.parameters + self.right.parameters
            return self._parameters!
        }
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
        if(self.isSimplified) { return self }

        let new = Assign(self.left.simplify(), self.right.simplify())
        try! new.setVariableOrder(from: self)
        new.isSimplified = false
        return new
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine("assign")
        hasher.combine(self.left)
        hasher.combine(self.right)
    }

    override public func swiftCode(using representations: Dictionary<Node, String>) throws -> String {
        throw SymbolicMathError.noCodeRepresentation("Assign node")
    }
}