import Foundation
import Numerics
import Collections

/// Subtract one node from the other.
public class Subtract: Node, Operation {
    
    public static let staticPrecedence: OperationPrecedence = OperationPrecedence(higherThan: Assign.staticPrecedence)
    public let precedence: OperationPrecedence = Subtract.staticPrecedence
    public let type: OperationType = .infix
    public let associativity: OperationAssociativity = .left
    public let identifier: String = "-"
    
    // Store the parameters for the node
    public var left: Node
    public var right: Node
    
    override public var description: String {
        var leftString = "\(self.left)"
        var rightString = "\(self.right)"
        
        // Wrap the sides if needed
        if let op = self.left as? Operation {
            if(op.precedence < self.precedence && op.type == .infix) {
                leftString = "(\(leftString))"
            }
        }
        if let op = self.right as? Operation {
            if(op.precedence < self.precedence && op.type == .infix) {
                rightString = "(\(rightString))"
            }
        }
        
        return "\(leftString)-\(rightString)"
    }
    
    override public var latex: String {
        return self.description
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
        return "subtraction\(hasher.finalize())"
    }
    
    required public init(_ params: [Node]) {
        self.left = params[0]
        self.right = params[1]
    }
    
    public func factory(_ params: [Node]) -> Node {
        return Self(params)
    }
    
    @inlinable
    override public func evaluate(withValues values: [Node: Double]) throws -> Double {
        return try self.left.evaluate(withValues: values) - self.right.evaluate(withValues: values)
    }

    override internal func equals(_ otherNode: Node) -> Bool {
        if let sub = otherNode as? Subtract {
            return self.left.equals(sub.left) && self.right.equals(sub.right)
        } else {
            return false
        }
    }

    override public func contains<T: Node>(nodeType: T.Type) -> [Id] {
        var ids: [Id] = []
        if(nodeType == Subtract.self) {
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
            return Subtract(self.left.replace(targetNode, with: replacement), self.right.replace(targetNode, with: replacement))
        }
    }

    public override func simplify() -> Node {

        if(self.isSimplified) { return self }

        let leftSimplified = self.left.simplify()
        let rightSimplified = self.right.simplify()

        // Test if both are numbers
        let leftIsNum = leftSimplified as? Number != nil
        let rightIsNum = rightSimplified as? Number != nil

        if(leftIsNum && rightIsNum) {
            let new = Number((leftSimplified as! Number).value - (rightSimplified as! Number).value)
            try! new.setVariableOrder(from: self)
            new.isSimplified = true
            return new
        }
        
        let new = Add(leftSimplified, Multiply(Number(-1), rightSimplified).simplify()).simplify()
        try! new.setVariableOrder(from: self)
        new.isSimplified = true
        return new
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine("subtract")
        hasher.combine(self.left)
        hasher.combine(self.right)
    }

    override public func swiftCode(using representations: Dictionary<Node, String>) throws -> String {
        return "(\(try self.left.swiftCode(using: representations)))-(\(try self.right.swiftCode(using: representations)))"
    }
}