// Created 2020 github @ianruh

public class Parameter: Node {
    private static var currentNameIndex: Int = 0

    internal static var nextName: String {
        self.currentNameIndex += 1
        return "$\(self.currentNameIndex)"
    }

    public var name: String

    override public var description: String {
        return self.name
    }

    override public var latex: String {
        return "\(self.name)"
    }

    override public var derivatives: Set<Derivative> {
        return []
    }

    override public var typeIdentifier: String {
        return self.name
    }

    override public var variables: Set<Variable> {
        if let variables = self._variables {
            return variables
        } else {
            self._variables = []
            return self._variables!
        }
    }

    override public var parameters: Set<Parameter> {
        if let parameters = self._parameters {
            return parameters
        } else {
            self._parameters = [self]
            return self._parameters!
        }
    }

    public static func == (_ lhs: Parameter, _ rhs: Parameter) -> Bool {
        return lhs.name == rhs.name
    }

    /// Initialize a variable using a string. The initial value is only used if the variable is the dependent variable in an ODE.
    ///
    /// - Parameters:
    ///   - str: String representation of the variable.
    ///   - initialValue: Initial value of the variable in an ODE. Won't be used and doesn't need to be specified if it is not the independent variable in an ODE.
    public init(_ str: String) {
        self.name = str
    }

    override public convenience init() {
        self.init(Self.nextName)
    }

    @inlinable
    override public func evaluate(withValues values: [Node: Double]) throws -> Double {
        if let value = values[self] {
            return value
        } else {
            throw SymbolicMathError.misc("No value provided for parameter \(self.name)")
        }
    }

    override internal func equals(_ otherNode: Node) -> Bool {
        if let parameter = otherNode as? Parameter {
            return self.name == parameter.name
        } else {
            return false
        }
    }

    override public func contains<T: Node>(nodeType: T.Type) -> [Id] {
        if nodeType == Parameter.self {
            return [self.id]
        } else {
            return []
        }
    }

    @discardableResult override public func replace(_ targetNode: Node, with replacement: Node) -> Node {
        if targetNode == self {
            return replacement
        } else {
            return self
        }
    }

    override public func simplify() -> Node {
        // Don't need to set variable order
        return self
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine("parameter")
        hasher.combine(self.name)
    }

    override public func swiftCode(using representations: [Node: String]) throws -> String {
        if let rep = representations[self] {
            return rep
        } else {
            throw SymbolicMathError.noCodeRepresentation("for parameter \(self)")
        }
    }
}

public extension Parameter {
    /// Construct an array of parameters with the given base name.
    /// - Parameters:
    ///   - name: The base name for the array.
    ///   - count: The length of the array.
    /// - Returns: An array of parameters  with the given base name and length.
    static func vector(_ name: String, count: Int) -> [Parameter] {
        var arr: [Parameter] = []
        for i in 0 ..< count {
            arr.append(Parameter("\(name)[\(i)]"))
        }
        return arr
    }

    /// Construct a matrix (really a doubly nested array) of parameters with the given base name.
    /// - Parameters:
    ///   - name: The base name for the matrix.
    ///   - rows: The number of rows of parameters.
    ///   - cols: The number of columns of parameters.
    /// - Returns: The double nested list of parameters.
    static func matrix(_ name: String, rows: Int, cols: Int) -> [[Parameter]] {
        var arrs: [[Parameter]] = []
        for i in 0 ..< rows {
            var arr: [Parameter] = []
            for j in 0 ..< cols {
                arr.append(Parameter("\(name)[\(i),\(j)]"))
            }
            arrs.append(arr)
        }
        return arrs
    }
}

public extension Array where Array.Element == [Parameter] {
    subscript(_ row: Int, _ col: Int) -> Parameter {
        return self[row][col]
    }
}
