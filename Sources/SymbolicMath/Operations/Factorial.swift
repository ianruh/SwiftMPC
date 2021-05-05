import Foundation
import Numerics

/// Factorial of a node.
public class Factorial: Node, Operation {
    
    public let precedence: OperationPrecedence = OperationPrecedence(higherThan: Power().precedence)
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
        return self.argument.variables
    }

    override public var derivatives: Set<Derivative> {
        return self.argument.derivatives
    }

    override public var typeIdentifier: String {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return "factorial\(hasher.finalize())"
    }
    
    required public init(_ params: [Node]) {
        self.argument = params[0]
    }

    public init(_ param: Node) {
        self.argument = param
    }

    override required public init() {
        self.argument = Node()
        super.init()
    }
    
    @inlinable
    override public func evaluate(withValues values: [Node: Double]) throws -> Double {
        // TODO: Factorial evaluation
        throw SymbolLabError.notApplicable(message: "Factorial not implemented for the moment")
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
        return Factorial(self.argument.simplify())
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine("factorial")
        hasher.combine(self.argument)
    }
}