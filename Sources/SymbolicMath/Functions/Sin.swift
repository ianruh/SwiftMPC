// Created 2020 github @ianruh

import Collections
import RealModule

public class Sin: Node, Function {
    public let identifier: String = "sin"
    public let numArguments: Int = 1

    // Store the parameters for the node
    public var argument: Node

    override public var description: String {
        return "sin(\(self.argument))"
    }

    override public var latex: String {
        return "\\sin(\(self.argument.latex))"
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
        return "sine\(hasher.finalize())"
    }

    public required init(_ params: [Node]) {
        self.argument = params[0]
    }

    public convenience init(_ param: Node) {
        self.init([param])
    }

    @inlinable
    override public func evaluate(withValues values: [Node: Double]) throws -> Double {
        return try Double.sin(self.argument.evaluate(withValues: values))
    }

    override internal func equals(_ otherNode: Node) -> Bool {
        if let sin = otherNode as? Sin {
            return self.argument.equals(sin.argument)
        } else {
            return false
        }
    }

    override public func contains<T: Node>(nodeType: T.Type) -> [Id] {
        var ids: [Id] = []
        if nodeType == Sin.self {
            ids.append(self.id)
        }
        ids.append(contentsOf: self.argument.contains(nodeType: nodeType))
        return ids
    }

    @discardableResult override public func replace(_ targetNode: Node, with replacement: Node) -> Node {
        if targetNode == self {
            return replacement
        } else {
            return Sin(self.argument.replace(targetNode, with: replacement))
        }
    }

    override public func simplify() -> Node {
        if self.isSimplified { return self }

        let new = Sin(self.argument.simplify())
        try! new.setVariableOrder(from: self)
        new.isSimplified = true
        return new
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine("sin")
        hasher.combine(self.argument)
    }

    override public func swiftCode(using representations: [Node: String]) throws -> String {
        return "Double.sin(\(try self.argument.swiftCode(using: representations)))"
    }
}
