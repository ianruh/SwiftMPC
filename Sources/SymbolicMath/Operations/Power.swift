import Foundation
import Numerics

/// Power of one node to the other.
public class Power: Node, Operation {
    
    public let precedence: OperationPrecedence = OperationPrecedence(higherThan: Negative().precedence)
    public let type: OperationType = .infix
    public let associativity: OperationAssociativity = .right
    public let identifier: String = "^"
    
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
        
        return "\(leftString)^\(rightString)"
    }
    
    override public var latex: String {
        var leftString = self.left.latex
        if let op = self.left as? Operation {
            if(op.precedence < self.precedence && op.type == .infix) {
                leftString = "(\(leftString))"
            }
        }
        return "\(leftString)^{\(self.right.latex)}"
    }
    
    override public var variables: Set<Variable> {
        return self.left.variables + self.right.variables
    }

    override public var parameters: Set<Parameter> {
        return self.left.parameters + self.right.parameters
    }

    override public var derivatives: Set<Derivative> {
        return self.left.derivatives + self.right.derivatives
    }

    override public var typeIdentifier: String {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return "power\(hasher.finalize())"
    }
    
    required public init(_ params: [Node]) {
        self.left = params[0]
        self.right = params[1]
    }

    public init(_ left: Node, _ right: Node) {
        self.left = left
        self.right = right
    }

    override required public init() {
        self.left = Node()
        self.right = Node()
        super.init()
    }
    
    @inlinable
    override public func evaluate(withValues values: [Node: Double]) throws -> Double {
        // Explanation for the weirdness here: https://github.com/apple/swift-numerics/pull/82

        let leftValue: Double = try self.left.evaluate(withValues: values)
        let rightValue: Double = try self.right.evaluate(withValues: values)

        if(leftValue >= 0) {
            return Double.pow(leftValue, rightValue)
        } else {
            if let rightValueInt = Int(exactly: rightValue) {
                return Double.pow(leftValue, rightValueInt)
            } else {
                throw SymbolicMathError.undefinedValue("Non-integer exponents of negatives are not currently supported: \(leftValue)^\(rightValue)")
            }
        }
    }

    override internal func equals(_ otherNode: Node) -> Bool {
        if let power = otherNode as? Power {
            return self.left.equals(power.left) && self.right.equals(power.right)
        } else {
            return false
        }
    }

    override public func contains<T: Node>(nodeType: T.Type) -> [Id] {
        var ids: [Id] = []
        if(nodeType == Power.self) {
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
            return Power(self.left.replace(targetNode, with: replacement), self.right.replace(targetNode, with: replacement))
        }
    }

    public override func simplify() -> Node {
        let leftSimplified = self.left.simplify()
        let rightSimplified = self.right.simplify()

        let leftIsNum = leftSimplified as? Number != nil
        let rightIsNum = rightSimplified as? Number != nil

        if(rightIsNum && (rightSimplified as! Number) == Number(1)) {
            let new = leftSimplified
            new.setVariableOrder(self.orderedVariables)
            return new
        } else if(rightIsNum && (rightSimplified as! Number) == Number(0)) {
            let new = Number(1)
            new.setVariableOrder(self.orderedVariables)
            return new
        } else if(leftIsNum && rightIsNum) {
            // Explanation for the weirdness here: https://github.com/apple/swift-numerics/pull/82
            let leftValue = (leftSimplified as! Number).value
            let rightValue = (rightSimplified as! Number).value
            if(leftValue > 0) {
                let new = Number(Double.pow(leftValue, rightValue))
                new.setVariableOrder(self.orderedVariables)
                return new
            } else {
                if let rightValueInt = Int(exactly: rightValue) {
                    let new = Number(Double.pow(leftValue, rightValueInt))
                    new.setVariableOrder(self.orderedVariables)
                    return new
                } else {
                    let new = Power(leftSimplified, rightSimplified)
                    new.setVariableOrder(self.orderedVariables)
                    return new
                }
            }
        }

        let new = Power(leftSimplified, rightSimplified)
        new.setVariableOrder(self.orderedVariables)
        return new
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine("power")
        hasher.combine(self.left)
        hasher.combine(self.right)
    }

    override public func swiftCode(using representations: Dictionary<Node, String>) throws -> String {
        return "Double.pow(\(try self.left.swiftCode(using: representations)), \(try self.right.swiftCode(using: representations)))"
    }
}