import Numerics
import Collections

/// Add one node to the other.
public class Add: Node, Operation {
    
    public let precedence: OperationPrecedence = OperationPrecedence(higherThan: Assign(Node(), Node()).precedence)
    public let type: OperationType = .infix
    public let associativity: OperationAssociativity = .left
    public let identifier: String = "+"
    
    // Store the parameters for the node
    public var arguments: [Node]
    
    override public var description: String {
        var str = ""

        // Handle if there is only one child
        if(self.arguments.count == 1) {
            return self.arguments[0].description
        }

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
            str += "+"
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
        return "addition\(hasher.finalize())"
    }
    
    required public init(_ params: [Node]) {
        self.arguments = params
        super.init()
        self.variables = self.arguments.reduce(Set<Variable>(), {(currentSet, nextArg) in
            return currentSet + nextArg.variables
        })
        self.orderedVariables = OrderedSet<Variable>(self.variables.sorted())
        self.parameters = self.arguments.reduce(Set<Parameter>(), {(currentSet, nextArg) in
            return currentSet + nextArg.parameters
        })
    }

    // override required public init() {
    //     self.arguments = []
    //     super.init()
    // }

    public convenience init(_ params: Node...) {
        self.init(params)
    }
    
    @inlinable
    override public func evaluate(withValues values: [Node : Double]) throws -> Double {
        var sum: Double = 0
        for arg in self.arguments {
            sum = try sum + arg.evaluate(withValues: values)
        }
        return sum
    }

    override internal func equals(_ otherNode: Node) -> Bool {
        if let add = otherNode as? Add {
            if(self.arguments.count == add.arguments.count) {
                var isEqual = true
                for i in 0..<self.arguments.count {
                    isEqual = isEqual && (self.arguments[i].equals(add.arguments[i]))
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
        if(nodeType == Add.self) {
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
            return Add(self.arguments.map({$0.replace(targetNode, with: replacement)}))
        }
    }

    public override func simplify() -> Node {

        if(self.isSimplified) { return self }

        func level(_  node: Add) -> Add {
            // Leveling of any addition operators to one operator
            var leveled: [Node] = []
            for term in node.arguments {
                if let add = term as? Add {
                    leveled.append(contentsOf: add.arguments)
                } else {
                    leveled.append(term)
                }
            }
            return Add(leveled)
        }

        func combineNumbers(_ node: Add) -> Add {
            // Combine numbers
            var numbers: [Number] = []
            var other: [Node] = []
            for term in node.arguments {
                if let num = term as? Number {
                    numbers.append(num)
                } else {
                    other.append(term)
                }
            }
            // Add all the numbers found
            if(numbers.count > 1) {
                var sum: Double = 0
                for num in numbers {
                    sum += num.value
                }
                other.append(Number(sum))
            } else if(numbers.count == 1) {
                other.append(contentsOf: numbers)
            }
            return Add(other)
        }

        func combineLike(_ node: Add) -> Add {
            let args = node.arguments
            var reducedTerms: [Node] = []

            var termsDict: Dictionary<Node, Node> = [:]
            args.forEach({arg in
                if let mul = arg as? Multiply {
                    if(mul.arguments.count > 1) {
                        if let term = termsDict[mul.arguments[0]] {
                            termsDict[mul.arguments[0]] = term + Multiply(Array<Node>(mul.arguments[1..<mul.arguments.count]))
                        } else {
                            termsDict[mul.arguments[0]] = Multiply(Array<Node>(mul.arguments[1..<mul.arguments.count]))
                        }
                    } else {
                        if let term = termsDict[mul.arguments[0]] {
                            termsDict[mul.arguments[0]] = term + Number(1)
                        } else {
                            termsDict[mul.arguments[0]] = Number(1)
                        }
                    }
                } else {
                    if let term = termsDict[arg] {
                        termsDict[arg] = term + Number(1)
                    } else {
                        termsDict[arg] = Number(1)
                    }
                }
            })
            for (base, multiple) in termsDict {
                if(multiple == Number(1)) {
                    reducedTerms.append(base)
                } else {
                    reducedTerms.append(base * multiple.simplify())
                }
            }

            return Add(reducedTerms)
        }

        func sortNodes(_ node: Add) -> Add {
            return Add(node.arguments.sorted())
        }

        func removeZero(_ node: Add) -> Add {
            var args = node.arguments
            args.removeAll(where: {$0 == Number(0)})
            return Add(args)
        }

        func terminal(_ node: Add) -> Node {
            if(node.arguments.count == 1) {
                return node.arguments[0]
            } else if(node.arguments.count == 0) {
                return Number(0)
            } else {
                return node
            }
        }

        let args = self.arguments.map({$0.simplify()})
        var simplifiedAdd = Add(args)

        simplifiedAdd = level(simplifiedAdd)
        simplifiedAdd = combineNumbers(simplifiedAdd)
        simplifiedAdd = combineLike(simplifiedAdd)
        simplifiedAdd = sortNodes(simplifiedAdd)
        simplifiedAdd = removeZero(simplifiedAdd)

        let new = terminal(simplifiedAdd)
        try! new.setVariableOrder(self.orderedVariables)
        new.isSimplified = true
        return new
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine("add")
        hasher.combine(self.arguments)
    }

    override public func swiftCode(using representations: Dictionary<Node, String>) throws -> String {
        var str = ""

        for i in 0..<self.arguments.count-1 {
            str += "(\(try self.arguments[i].swiftCode(using: representations)))+"
        }
        str += "(\(try self.arguments.last!.swiftCode(using: representations)))"

        return str
    }
}