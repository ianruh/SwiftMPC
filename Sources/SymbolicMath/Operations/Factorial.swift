import Foundation
import RealModule
import Collections

/// Factorial of a node.
public class Factorial: Node, Operation {
    
    public static let staticPrecedence: OperationPrecedence = OperationPrecedence(higherThan: Power.staticPrecedence)
    public let precedence: OperationPrecedence = Factorial.staticPrecedence
    public let type: OperationType = .postfix
    public let associativity: OperationAssociativity = .none
    public let identifier: String = "!"
    
    // Store the parameters for the node
    private var argument: Node
    
    override public var description: String {
        // Wrap if needed
        if let op = self.argument as? Operation {
            if(op.type != .function) {
                return "(\(self.argument))!"
            }
        }
        
        return "\(self.argument)!"
    }
    
    override public var latex: String {
        // Wrap if needed
        if let op = self.argument as? Operation {
            if(op.type != .function) {
                return "(\(self.argument.latex))!"
            }
        }
        
        return "\(self.argument.latex)!"
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
        return "factorial\(hasher.finalize())"
    }
    
    required public convenience init(_ params: [Node]) {
        self.init(params[0])
    }

    public init(_ param: Node) {
        self.argument = param
    }
    
    @inlinable
    override public func evaluate(withValues values: [Node: Double]) throws -> Double {
        // TODO: Factorial evaluation
        throw SymbolicMathError.notApplicable(message: "Factorial not implemented for the moment")
    }

    override internal func equals(_ otherNode: Node) -> Bool {
        if let fact = otherNode as? Factorial {
            return self.argument.equals(fact.argument)
        } else {
            return false
        }
    }

    override public func contains<T: Node>(nodeType: T.Type) -> [Id] {
        var ids: [Id] = []
        if(nodeType == Factorial.self) {
            ids.append(self.id)
        }
        ids.append(contentsOf: self.argument.contains(nodeType: nodeType))
        return ids
    }

    @discardableResult override public func replace(_ targetNode: Node, with replacement: Node) -> Node {
        if(targetNode == self) {
            return replacement
        } else {
            return Factorial(self.argument.replace(targetNode, with: replacement))
        }
    }

    public override func simplify() -> Node {
        if(self.isSimplified) { return self }

        let new = Factorial(self.argument.simplify())
        try! new.setVariableOrder(from: self)
        new.isSimplified = true
        return new
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine("factorial")
        hasher.combine(self.argument)
    }

    override public func swiftCode(using representations: Dictionary<Node, String>) throws -> String {
        throw SymbolicMathError.noCodeRepresentation("Factorial node")
    }
}