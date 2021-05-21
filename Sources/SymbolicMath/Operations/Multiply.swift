import Foundation
import Numerics

/// Multiply one node by the other.
public class Multiply: Node, Operation {
    
    public let precedence: OperationPrecedence = OperationPrecedence(higherThan: Add().precedence)
    public let type: OperationType = .infix
    public let associativity: OperationAssociativity = .left
    public let identifier: String = "*"
    
    // Store the parameters for the node
    public var arguments: [Node]
    
    override public var description: String {
        var str = ""

        for i in 0..<self.arguments.count-1 {
            if let op = self.arguments[i] as? Operation {
                if(op.precedence <= self.precedence && op.type == .infix) {
                    str += "(\(op))"
                } else {
                    str += "\(op)"
                }
            } else {
                str += self.arguments[i].description
            }
            str += "*"
        }
        
        if let op = self.arguments[self.arguments.count-1] as? Operation {
            if(op.precedence <= self.precedence && op.type == .infix) {
                str += "(\(op))"
            } else {
                str += "\(op)"
            }
        } else {
            str += self.arguments[self.arguments.count-1].description
        }
        
        return str
    }
    
    override public var latex: String {
        return self.description
    }
    
    override public var variables: Set<Variable> {
        var variables: Set<Variable> = []
        
        for arg in self.arguments {
            variables = variables + arg.variables
        }

        return variables
    }

    override public var parameters: Set<Parameter> {
        var parameters: Set<Parameter> = []
        
        for arg in self.arguments {
            parameters = parameters + arg.parameters
        }

        return parameters
    }

    override public var derivatives: Set<Derivative> {
        var derivatives: Set<Derivative> = []
        
        for arg in self.arguments {
            derivatives = derivatives + arg.derivatives
        }

        return derivatives
    }

    override public var typeIdentifier: String {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return "multiplication\(hasher.finalize())"
    }
    
    required public init(_ params: [Node]) {
        self.arguments = params
    }

    override required public init() {
        self.arguments = []
        super.init()
    }

    public convenience init(_ params: Node...) {
        self.init(params)
    }
    
    @inlinable
    override public func evaluate(withValues values: [Node: Double]) throws -> Double {
        var current: Double = 1
        for arg in self.arguments {
            current *= try arg.evaluate(withValues: values)
        }
        return current
    }

    override internal func equals(_ otherNode: Node) -> Bool {
        if let mul = otherNode as? Multiply {
            if(self.arguments.count == mul.arguments.count) {
                var isEqual = true
                for i in 0..<self.arguments.count {
                    isEqual = isEqual && (self.arguments[i].equals(mul.arguments[i]))
                }
                return isEqual
            } else {
                return false
            }
        } else {
            return false
        }
    }

    override public func contains<T: Node>(nodeType: T.Type) -> [Id] {
        var ids: [Id] = []
        if(nodeType == Multiply.self) {
            ids.append(self.id)
        }
        for arg in self.arguments {
            ids.append(contentsOf: arg.contains(nodeType: nodeType))
        }

        return ids
    }

    @discardableResult override public func replace(_ targetNode: Node, with replacement: Node) -> Node {
        if(targetNode == self) {
            return replacement
        } else {
            return Multiply(self.arguments.map({$0.replace(targetNode, with: replacement)}))
        }
    }

    public override func simplify() -> Node {

        if(self.isSimplified) { return self }

        func level(_ node: Multiply) -> Multiply {
            // Level the operator to only one level of multipliation
            var leveled: [Node] = []
            for term in node.arguments {
                if let mul = term as? Multiply {
                    leveled.append(contentsOf: mul.arguments)
                } else {
                    leveled.append(term)
                }
            }
            return Multiply(leveled)
        }

        func combineNumbers(_ node: Multiply) -> Multiply {
            // combine all numbers
            var numbers: [Number] = []
            var other: [Node] = []
            for term in node.arguments {
                if let num = term as? Number {
                    numbers.append(num)
                } else {
                    other.append(term)
                }
            }
            if(numbers.count > 1) {
                var sum: Double = 1
                for num in numbers {
                    sum *= num.value
                }
                other.append(Number(sum))
            } else if(numbers.count == 1) {
                other.append(contentsOf: numbers)
            }
            return Multiply(other)
        }

        func fractionProduct(_ node: Multiply) -> Node {
            // We want (a/b)*(c/d) --> (a*c)/(b*d)
            var tops: [Node] = []
            var bottoms: [Node] = []
            for term in node.arguments {
                if let div = term as? Divide {
                    tops.append(div.left)
                    bottoms.append(div.right)
                } else {
                    tops.append(term)
                }
            }

            tops.sort()
            bottoms.sort()

            // We call simplify again because not everything may be level anymore
            if(bottoms.count == 0) {
                if(tops.count == 1) {
                    return tops[0]
                } else {
                    return Multiply(tops)
                }
            } else if(bottoms.count == 1) {
                if(tops.count == 1) {
                    return Divide(tops[0], bottoms[0]).simplify()
                } else {
                    return Divide(Multiply(tops).simplify(), bottoms[0]).simplify()
                }
            } else {
                if(tops.count == 1) {
                    return Divide(tops[0], Multiply(bottoms).simplify()).simplify()
                } else {
                    return Divide(Multiply(tops).simplify(), Multiply(bottoms).simplify()).simplify()
                }
            }
        }

        func combineLike(_ node: Multiply) -> Multiply {
            var args = node.arguments
            var reducedTerms: [Node] = []
            var i = 0
            while(i < args.count) {
                var current = args[i]
                var exponent: Node = Number(1)
                if let pow = current as? Power {
                    current = pow.left
                    exponent = pow.right
                }
                var j = i + 1
                while(j < args.count) {
                    if(args[j] == current) {
                        exponent = Add(exponent, Number(1))
                        args.remove(at: args.startIndex + j)
                        j -= 1
                    } else if let pow = args[j] as? Power {
                        if(pow.left == current) {
                            exponent = Add(exponent, pow.right)
                            args.remove(at: args.startIndex + j)
                            j -= 1
                        }
                    }
                    j += 1
                }

                reducedTerms.append(Power(current, exponent).simplify())
                i += 1
            }

            return Multiply(reducedTerms)
        }

        func removeOne(_ node: Multiply) -> Multiply {
            var args = node.arguments
            args.removeAll(where: {$0 == Number(1)})
            return Multiply(args)
        }

        let args = self.arguments.map({$0.simplify()})

        var simplifiedMul = Multiply(args)
        simplifiedMul = level(simplifiedMul)
        simplifiedMul = combineNumbers(simplifiedMul)
        simplifiedMul = combineLike(simplifiedMul)
        simplifiedMul = removeOne(simplifiedMul)

        // Idk why, but combineLike seems to put multiples nested.
        // TODO: Figure out why, something in combineLike. Look at second test in testDerivativeCos
        // for an example of an issue.
        simplifiedMul = level(simplifiedMul)
        simplifiedMul = combineNumbers(simplifiedMul)

        if(simplifiedMul.arguments.contains(Number(0))) {
            let new = Number(0)
            new.setVariableOrder(self.orderedVariables)
            new.isSimplified = true
            return new
        } else if(simplifiedMul.arguments.count == 1) {
            let new = simplifiedMul.arguments[0]
            new.setVariableOrder(self.orderedVariables)
            new.isSimplified = true
            return new
        } else if(simplifiedMul.arguments.count == 0) {
            let new = Number(1)
            new.setVariableOrder(self.orderedVariables)
            new.isSimplified = true
            return new
        }

        let new = fractionProduct(simplifiedMul)
        new.setVariableOrder(self.orderedVariables)
        new.isSimplified = true
        return new
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine("multiply")
        hasher.combine(self.arguments)
    }

    override public func swiftCode(using representations: Dictionary<Node, String>) throws -> String {
        var str = ""

        for i in 0..<self.arguments.count-1 {
            str += "(\(try self.arguments[i].swiftCode(using: representations)))*"
        }
        str += "(\(try self.arguments.last!.swiftCode(using: representations)))"

        return str
    }
}