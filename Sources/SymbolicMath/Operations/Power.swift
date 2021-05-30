import Foundation
import Numerics
import Collections

/// Power of one node to the other.
public class Power: Node, Operation {
    
    public static let staticPrecedence: OperationPrecedence = OperationPrecedence(higherThan: Negative.staticPrecedence)
    public let precedence: OperationPrecedence = Power.staticPrecedence
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
        return "power\(hasher.finalize())"
    }
    
    required public convenience init(_ params: [Node]) {
        self.init(params[0], params[1])
    }

    public init(_ left: Node, _ right: Node) {
        self.left = left
        self.right = right
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

        if(self.isSimplified) { return self }

        let leftSimplified = self.left.simplify()
        let rightSimplified = self.right.simplify()

        let leftIsNum = leftSimplified as? Number != nil
        let rightIsNum = rightSimplified as? Number != nil

        if(rightIsNum && (rightSimplified as! Number) == Number(1)) {
            let new = leftSimplified
            try! new.setVariableOrder(from: self)
            new.isSimplified = true
            return new
        } else if(rightIsNum && (rightSimplified as! Number) == Number(0)) {
            let new = Number(1)
            try! new.setVariableOrder(from: self)
            new.isSimplified = true
            return new
        } else if(leftIsNum && rightIsNum) {
            // Explanation for the weirdness here: https://github.com/apple/swift-numerics/pull/82
            let leftValue = (leftSimplified as! Number).value
            let rightValue = (rightSimplified as! Number).value
            if(leftValue > 0) {
                let new = Number(Double.pow(leftValue, rightValue))
                try!  new.setVariableOrder(from: self)
                new.isSimplified = true
                return new
            } else {
                if let rightValueInt = Int(exactly: rightValue) {
                    let new = Number(Double.pow(leftValue, rightValueInt))
                    try! new.setVariableOrder(from: self)
                    new.isSimplified = true
                    return new
                } else {
                    let new = Power(leftSimplified, rightSimplified)
                    try! new.setVariableOrder(from: self)
                    new.isSimplified = true
                    return new
                }
            }
        }

        let new = Power(leftSimplified, rightSimplified)
        try! new.setVariableOrder(self.orderedVariables)
        new.isSimplified = true
        return new
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine("power")
        hasher.combine(self.left)
        hasher.combine(self.right)
    }

    override public func swiftCode(using representations: Dictionary<Node, String>) throws -> String {

        // You can thank [this issue](https://github.com/apple/swift-numerics/pull/82) for the weirdness here.
        guard let rightSideNumber = self.right as? Number else {
            throw SymbolicMathError.misc("The exponent for a power must be a number, not \(self.right)(\(self.right.typeIdentifier))")
        }
        guard let rightSide: Int = Int(exactly: try rightSideNumber.evaluate(withValues: [:])) else {
            throw SymbolicMathError.misc("Power must be an integer, not \(rightSideNumber)")
        }

        return "Double.pow(\(try self.left.swiftCode(using: representations)), \(rightSide))"
    }
}