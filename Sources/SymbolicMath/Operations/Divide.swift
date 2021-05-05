import Numerics

/// Divide one node by the other.
public class Divide: Node, Operation {
    
    public let precedence: OperationPrecedence = OperationPrecedence(higherThan: Add().precedence)
    public let type: OperationType = .infix
    public let associativity: OperationAssociativity = .left
    public let identifier: String = "/"
    
    // Store the parameters for the node
    public var left: Node
    public var right: Node
    
    override public var description: String {
        var leftString = "\(self.left)"
        var rightString = "\(self.right)"
        
        // Wrap the sides if needed
        if let op = self.left as? Operation {
            if(op.precedence <= self.precedence && op.type == .infix) {
                leftString = "(\(leftString))"
            }
        }
        if let op = self.right as? Operation {
            if(op.precedence <= self.precedence && op.type == .infix) {
                rightString = "(\(rightString))"
            }
        }
        
        return "\(leftString)/\(rightString)"
    }
    
    override public var latex: String {
        return "\\frac{\(self.left.latex)}{\(self.right.latex)}"
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
        return "division\(hasher.finalize())"
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
        return try self.left.evaluate(withValues: values) / self.right.evaluate(withValues: values)
    }

    override internal func equals(_ otherNode: Node) -> Bool {
        if let div = otherNode as? Divide {
            return self.left.equals(div.left) && self.right.equals(div.right)
        } else {
            return false
        }
    }

    override public func contains<T: Node>(nodeType: T.Type) -> [Id] {
        var ids: [Id] = []
        if(nodeType == Divide.self) {
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
            return Divide(self.left.replace(targetNode, with: replacement), self.right.replace(targetNode, with: replacement))
        }
    }
    
    public override func simplify() -> Node {
        func toMulPowers(_ node: Node) -> Multiply {
            switch node {
            case let mul as Multiply:
                return Multiply(mul.arguments.map({
                    if let pow = $0 as? Power {
                        return pow
                    } else {
                        return Power($0, Number(1))
                    }
                }))
            case let pow as Power:
                return Multiply(pow, Power(Number(1), Number(1)))
            default:
                return Multiply(Power(node, Number(1)), Power(Number(1), Number(1)))
            }
        }

        func cancelTerms(_ node: Divide) -> Node {
            var leftTerms: [Power] = toMulPowers(node.left).arguments as! [Power]
            var rightTerms: [Power] = toMulPowers(node.right).arguments as! [Power]

            for i in 0..<leftTerms.count {
                for j in 0..<rightTerms.count {
                    // Check the bases are the same
                    if(leftTerms[i].left == rightTerms[j].left) {
                        if(leftTerms[i].right > rightTerms[j].right) {
                            leftTerms[i] = Power(leftTerms[i].left, Subtract(leftTerms[i].right, rightTerms[j].right))
                            rightTerms[j] = Power(Number(1), Number(1))
                        } else if(leftTerms[i].right < rightTerms[j].right) {
                            rightTerms[j] = Power(rightTerms[j].left, Subtract(rightTerms[j].right, leftTerms[i].right))
                            leftTerms[i] = Power(Number(1), Number(1))
                        } else {
                            rightTerms[j] = Power(Number(1), Number(1))
                            leftTerms[i] = Power(Number(1), Number(1))
                        }
                    }
                }
            }

            let leftSimplified = Multiply(leftTerms).simplify()
            let rightSimplified = Multiply(rightTerms).simplify()

            if(rightSimplified == Number(1)) {
                return leftSimplified
            } else {
                return Divide(leftSimplified, rightSimplified)
            }
        }

        let leftSimplified = self.left.simplify()
        let rightSimplified = self.right.simplify()

        let leftIsNum = leftSimplified as? Number != nil
        let rightIsNum = rightSimplified as? Number != nil

        // Combine numbers into one
        if(leftIsNum && rightIsNum) {
            let rightValue = (rightSimplified as! Number).value
            guard rightValue != 0.0 else {
                return Divide(leftSimplified, rightSimplified)
            }
            return Number((leftSimplified as! Number).value / rightValue)
        }

        let leftIsDiv = leftSimplified as? Divide != nil
        let rightIsDiv = rightSimplified as? Divide != nil

        if(leftIsDiv && rightIsDiv) {
            // We want (a/b)/(c/d) --> (a*d)/(b*c)
            let leftDiv = leftSimplified as! Divide
            let rightDiv = rightSimplified as! Divide
            return Divide(leftDiv.left * rightDiv.right, leftDiv.right * rightDiv.left).simplify()
        } else if(leftIsDiv && !rightIsDiv) {
            // We want to simplify (a/b)/c --> a/(b*c)
            let leftDiv = leftSimplified as! Divide
            return Divide(leftDiv.left, leftDiv.right * rightSimplified).simplify()
        } else if(!leftIsDiv && rightIsDiv) {
            // We want a/(b/c) --> (a*c)/b
            let rightDiv = rightSimplified as! Divide
            return Divide(leftSimplified*rightDiv.right, rightDiv.left).simplify()
        } else {
            // Default case
            if(rightSimplified == Number(1)) {
                return leftSimplified
            } else if(leftSimplified == Number(0.0)) {
                return Number(0.0)
            } else {
                var simplifiedDiv: Divide = Divide(leftSimplified, rightSimplified)
                return cancelTerms(simplifiedDiv)
            }
        }
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine("divide")
        hasher.combine(self.left)
        hasher.combine(self.right)
    }
}