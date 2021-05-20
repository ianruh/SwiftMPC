import Numerics

/// Add one node to the other.
public class Add: Node, Operation {
    
    public let precedence: OperationPrecedence = OperationPrecedence(higherThan: Assign().precedence)
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
            parameters = parameters.union(arg.parameters)
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
        return "addition\(hasher.finalize())"
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
            var args = node.arguments
            var reducedTerms: [Node] = []
            var i = 0
            while(i < args.count) {
                var current = args[i]
                var multiple: Node = Number(1)
                if let mul = current as? Multiply {
                    current = mul.arguments[0]
                    multiple = Multiply(Array<Node>(mul.arguments[1..<mul.arguments.count])).simplify()
                }
                var j = i + 1
                while(j < args.count) {
                    if(args[j] == current) {
                        multiple = Add(multiple, Number(1))
                        args.remove(at: args.startIndex + j)
                        j -= 1
                    } else if let mul = args[j] as? Multiply {
                        if(current == mul.arguments[0]) {
                            multiple = Add(multiple, Multiply(Array<Node>(mul.arguments[1..<mul.arguments.count])).simplify())
                            args.remove(at: args.startIndex + j)
                            j -= 1
                        }
                    }
                    j += 1
                }

                reducedTerms.append(Multiply(current, multiple).simplify())
                i += 1
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

        return terminal(simplifiedAdd)
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