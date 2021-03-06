// Created 2020 github @ianruh

import Collections
import RealModule

/// Add one node to the other.
public class Add: Node, Operation {
    public static let staticPrecedence = OperationPrecedence(higherThan: Assign.staticPrecedence)
    public let precedence: OperationPrecedence = Add.staticPrecedence
    public let type: OperationType = .infix
    public let associativity: OperationAssociativity = .left
    public let identifier: String = "+"

    // Store the parameters for the node
    public var arguments: [Node]

    override public var description: String {
        var str = ""

        // Handle if there is only one child
        if self.arguments.count == 1 {
            return self.arguments[0].description
        }

        for i in 0 ..< self.arguments.count - 1 {
            if let op = self.arguments[i] as? Operation {
                if op.precedence <= self.precedence, op.type == .infix {
                    str += "(\(op))"
                } else {
                    str += "\(op)"
                }
            } else {
                str += self.arguments[i].description
            }
            str += "+"
        }

        if let op = self.arguments[self.arguments.count - 1] as? Operation {
            if op.precedence <= self.precedence, op.type == .infix {
                str += "(\(op))"
            } else {
                str += "\(op)"
            }
        } else {
            str += self.arguments[self.arguments.count - 1].description
        }

        return str
    }

    override public var latex: String {
        return self.description
    }

    override public var variables: Set<Variable> {
        if let variables = self._variables {
            return variables
        } else {
            self._variables = self.arguments.reduce(Set<Variable>()) { currentSet, nextArg in
                currentSet + nextArg.variables
            }
            return self._variables!
        }
    }

    override public var parameters: Set<Parameter> {
        if let parameters = self._parameters {
            return parameters
        } else {
            self._parameters = self.arguments.reduce(Set<Parameter>()) { currentSet, nextArg in
                currentSet + nextArg.parameters
            }
            return self._parameters!
        }
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

    public required init(_ params: [Node]) {
        self.arguments = params
    }

    // override required public init() {
    //     self.arguments = []
    //     super.init()
    // }

    public convenience init(_ params: Node...) {
        self.init(params)
    }

    @inlinable
    override public func evaluate(withValues values: [Node: Double]) throws -> Double {
        var sum: Double = 0
        for arg in self.arguments {
            sum = try sum + arg.evaluate(withValues: values)
        }
        return sum
    }

    override internal func equals(_ otherNode: Node) -> Bool {
        if let add = otherNode as? Add {
            if self.arguments.count == add.arguments.count {
                var isEqual = true
                for i in 0 ..< self.arguments.count {
                    isEqual = isEqual && self.arguments[i].equals(add.arguments[i])
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
        if nodeType == Add.self {
            ids.append(self.id)
        }
        for arg in self.arguments {
            ids.append(contentsOf: arg.contains(nodeType: nodeType))
        }

        return ids
    }

    @discardableResult override public func replace(_ targetNode: Node, with replacement: Node) -> Node {
        if targetNode == self {
            return replacement
        } else {
            return Add(self.arguments.map { $0.replace(targetNode, with: replacement) })
        }
    }

    override public func simplify() -> Node {
        if self.isSimplified { return self }

        func level(_ node: Add) -> Add {
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
            if numbers.count > 1 {
                var sum: Double = 0
                for num in numbers {
                    sum += num.value
                }
                other.append(Number(sum))
            } else if numbers.count == 1 {
                other.append(contentsOf: numbers)
            }
            return Add(other)
        }

        func combineLike(_ node: Add) -> Add {
            let args = node.arguments
            var reducedTerms: [Node] = []

            var termsDict: [Node: Node] = [:]
            args.forEach { arg in

                // NOTE: This section is commented out because we want simplify to expand, rather than factor, terms.
                // I'm not sure if I'll want it later, so commenting for now, rather than deleting. If you are reading this
                // later, you can likely delete it safely.

                // if let mul = arg as? Multiply {
                //     if(mul.arguments.count > 1) {
                //         if let term = termsDict[mul.arguments[0]] {
                //             termsDict[mul.arguments[0]] = term + Multiply(Array<Node>(mul.arguments[1..<mul.arguments.count]))
                //         } else {
                //             termsDict[mul.arguments[0]] = Multiply(Array<Node>(mul.arguments[1..<mul.arguments.count]))
                //         }
                //     } else {
                //         if let term = termsDict[mul.arguments[0]] {
                //             termsDict[mul.arguments[0]] = term + Number(1)
                //         } else {
                //             termsDict[mul.arguments[0]] = Number(1)
                //         }
                //     }
                // } else {
                if let term = termsDict[arg] {
                    termsDict[arg] = term + Number(1)
                } else {
                    termsDict[arg] = Number(1)
                }
                // }
            }
            for (base, multiple) in termsDict {
                if multiple == Number(1) {
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
            args.removeAll(where: { $0 == Number(0) })
            return Add(args)
        }

        func terminal(_ node: Add) -> Node {
            if node.arguments.count == 1 {
                return node.arguments[0]
            } else if node.arguments.count == 0 {
                return Number(0)
            } else {
                return node
            }
        }

        let args = self.arguments.map { $0.simplify() }
        var simplifiedAdd = Add(args)

        simplifiedAdd = level(simplifiedAdd)
        simplifiedAdd = combineNumbers(simplifiedAdd)
        simplifiedAdd = combineLike(simplifiedAdd)
        simplifiedAdd = sortNodes(simplifiedAdd)
        simplifiedAdd = removeZero(simplifiedAdd)

        let new = terminal(simplifiedAdd)
        try! new.setVariableOrder(from: self)
        new.isSimplified = true
        return new
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine("add")
        hasher.combine(self.arguments)
    }

    override public func swiftCode(using representations: [Node: String]) throws -> String {
        var str = ""

        // Handle if there is only one child
        if self.arguments.count == 1 {
            return try self.arguments[0].swiftCode(using: representations)
        }

        for i in 0 ..< self.arguments.count {
            if let op = self.arguments[i] as? Operation {
                if op.precedence <= self.precedence, op.type == .infix {
                    str += "(\(try op.swiftCode(using: representations)))"
                } else {
                    str += "\(try op.swiftCode(using: representations))"
                }
            } else {
                str += try self.arguments[i].swiftCode(using: representations)
            }
            if i != self.arguments.count - 1 {
                str += " + "
            }
        }

        return str
    }
}
