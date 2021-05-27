
public class Variable: Node, ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    private static var currentNameIndex: Int = 0

    internal static var nextName: String {
        self.currentNameIndex += 1
        return "$\(self.currentNameIndex)"
    }

    public var string: String
    
    override public var description: String {
        return self.string
    }
    
    override public var latex: String {
        return "\(self.string)"
    }

    override public var derivatives: Set<Derivative> {
        return []
    }

    override public var typeIdentifier: String {
        return self.string
    }

    override public var variables: Set<Variable> {
        if let variables = self._variables {
            return variables
        } else {
            self._variables = [self]
            return self._variables!
        }
    }

    override public var parameters: Set<Parameter> {
        if let parameters = self._parameters {
            return parameters
        } else {
            self._parameters = []
            return self._parameters!
        }
    }

    public static func ==(_ lhs: Variable, _ rhs: Variable) -> Bool {
        return lhs.string == rhs.string
    }
    
    public required init(stringLiteral str: String) {
        self.string = str
    }

    /// Initialize a variable using a string. The initial value is only used if the variable is the dependent variable in an ODE.
    ///
    /// - Parameters:
    ///   - str: String representation of the variable.
    ///   - initialValue: Initial value of the variable in an ODE. Won't be used and doesn't need to be specified if it is not the independent variable in an ODE.
    public convenience init(_ str: String) {
        self.init(stringLiteral: str)
    }

    override public convenience init() {
        self.init(stringLiteral: Self.nextName)
    }
    
    @inlinable
    override public func evaluate(withValues values: [Node : Double]) throws -> Double {
        if let value  = values[self] {
            return value
        } else {
            throw SymbolicMathError.noValue(forVariable: self.description)
        }
    }

    override internal func equals(_ otherNode: Node) -> Bool {
        if let variable = otherNode as? Variable {
            return self.string == variable.string
        } else {
            return false
        }
    }

    override public func contains<T: Node>(nodeType: T.Type) -> [Id] {
        if(nodeType == Variable.self) {
            return [self.id]
        } else {
            return []
        }
    }

    @discardableResult override public func replace(_ targetNode: Node, with replacement: Node) -> Node {
        if(targetNode == self) {
            return replacement
        } else {
            return self
        }
    }

    override public func simplify() -> Node {
        // Don't need to set ordering
        return self
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine("variable")
        hasher.combine(self.string)
    }

    override public func swiftCode(using representations: Dictionary<Node, String>) throws -> String {
        if let rep = representations[self] {
            return rep
        } else {
            throw SymbolicMathError.noCodeRepresentation("\(self)")
        }
    }
}


public extension Variable {

    static func vector(_ name: String, count: Int) -> [Variable] {
        var arr: [Variable] = []
        for i in 0..<count {
            arr.append(Variable("\(name)[\(i)]"))
        }
        return arr
    }

    static func matrix(_ name: String, rows: Int, cols: Int) -> [[Variable]] {
        var arrs: [[Variable]] = []
        for i in 0..<rows {
            var arr: [Variable] = []
            for j in 0..<cols {
                arr.append(Variable("\(name)[\(i),\(j)]"))
            }
            arrs.append(arr)
        }
        return arrs
    }

}

public extension Array where Array.Element == Array<Variable> {
    subscript(_ row: Int, _ col: Int) -> Variable {
        return self[row][col]
    }
}