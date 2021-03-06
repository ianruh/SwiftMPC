// Created 2020 github @ianruh

import Collections
import RealModule

public class Exp: Node, Function {
    public let identifier: String = "exp"
    public let numArguments: Int = 1

    // Store the parameters for the node
    public var argument: Node

    override public var description: String {
        return "exp(\(self.argument))"
    }

    override public var latex: String {
        return "e^{\(self.argument.latex)}"
    }

    override public var variables: Set<Variable> {
        if let variables = self._variables {
            return variables
        } else {
            self._variables = self.argument.variables
            return self._variables!
        }
    }

    override public var parameters: Set<Parameter> {
        if let parameters = self._parameters {
            return parameters
        } else {
            self._parameters = self.argument.parameters
            return self._parameters!
        }
    }

    override public var derivatives: Set<Derivative> {
        return self.argument.derivatives
    }

    override public var typeIdentifier: String {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return "exponential\(hasher.finalize())"
    }

    public required init(_ params: [Node]) {
        self.argument = params[0]
    }

    public convenience init(_ param: Node) {
        self.init([param])
    }

    @inlinable
    override public func evaluate(withValues values: [Node: Double]) throws -> Double {
        return try Double.exp(self.argument.evaluate(withValues: values))
    }

    override internal func equals(_ otherNode: Node) -> Bool {
        if let exp = otherNode as? Exp {
            return self.argument.equals(exp.argument)
        } else {
            return false
        }
    }

    override public func contains<T: Node>(nodeType: T.Type) -> [Id] {
        var ids: [Id] = []
        if nodeType == Exp.self {
            ids.append(self.id)
        }
        ids.append(contentsOf: self.argument.contains(nodeType: nodeType))
        return ids
    }

    override public func simplify() -> Node {
        if self.isSimplified { return self }

        let simplifiedArg = self.argument.simplify()

        if simplifiedArg == Number(0) {
            let new = Number(1)
            try! new.setVariableOrder(from: self)
            new.isSimplified = true
            return new
        }

        let new = Exp(simplifiedArg)
        try! new.setVariableOrder(from: self)
        new.isSimplified = true
        return new
    }

    @discardableResult override public func replace(_ targetNode: Node, with replacement: Node) -> Node {
        if targetNode == self {
            return replacement
        } else {
            return Exp(self.argument.replace(targetNode, with: replacement))
        }
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine("exp")
        hasher.combine(self.argument)
    }

    override public func swiftCode(using representations: [Node: String]) throws -> String {
        return "Double.exp(\(try self.argument.swiftCode(using: representations)))"
    }
}
