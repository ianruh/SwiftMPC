// Created 2020 github @ianruh

public class BinaryVariable: Node, ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    private static var currentNameIndex: Int = 0

    internal static var nextName: String {
        self.currentNameIndex += 1
        return "$b\(self.currentNameIndex)"
    }

    /// The name of the binary variable
    public var string: String

    /// The two allowed values for the binary variable
    public var values: (one: Int, two: Int)

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
            self._variables = []
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

    public static func == (_ lhs: BinaryVariable, _ rhs: BinaryVariable) -> Bool {
        return lhs.string == rhs.string && lhs.values == rhs.values
    }

    /// Uses the default values of 0 and 1
    public required init(stringLiteral str: String) {
        self.string = str
        self.values = (0, 1)
    }

    /// Initialize a variable using a string. The initial value is only used
    /// if the variable is the dependent variable in an ODE.
    ///
    /// - Parameters:
    ///   - str: String representation of the variable.
    ///   - initialValue: Initial value of the variable in an ODE. Won't be
    ///     used and doesn't need to be specified if it is not the independent
    ///     variable in an ODE.
    public convenience init(_ str: String, values: (one: Int, two: Int) = (0, 1)) {
        self.init(stringLiteral: str)
        self.values = values
    }

    /// Uses a generated name and assumes binary values of 0 and 1
    override public convenience init() {
        self.init(stringLiteral: Self.nextName)
    }

    @inlinable
    override public func evaluate(withValues values: [Node: Double]) throws -> Double {
        if let value = values[self] {
            guard value == Double(self.values.one) || value == Double(self.values.two) else {
                throw SymbolicMathError.badValue("\(self) can only " +
                    "take on one of [\(self.values.one),\(self.values.two)] " +
                    ", not \(value)")
            }
            return value
        } else {
            throw SymbolicMathError.noValue(forVariable: self.description)
        }
    }

    override internal func equals(_ otherNode: Node) -> Bool {
        if let variable = otherNode as? BinaryVariable {
            return self.string == variable.string &&
                self.values == variable.values
        } else {
            return false
        }
    }

    override public func contains<T: Node>(nodeType: T.Type) -> [Id] {
        if nodeType == BinaryVariable.self {
            return [self.id]
        } else {
            return []
        }
    }

    @discardableResult override public func replace(_ targetNode: Node,
                                                    with replacement: Node) -> Node
    {
        if targetNode == self {
            return replacement
        } else {
            return self
        }
    }

    override public func simplify() -> Node {
        return self
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine("binary_variable")
        hasher.combine(self.string)
        hasher.combine(self.values.one)
        hasher.combine(self.values.two)
    }

    override public func swiftCode(using representations: [Node: String]) throws -> String {
        if let rep = representations[self] {
            return rep
        } else {
            throw SymbolicMathError.noCodeRepresentation("\(self)")
        }
    }
}

//====== Commented out for now, maybe use later ======

// public extension Variable {
//
//    /// Construct an array of variables with the given base name.
//    /// - Parameters:
//    ///   - name: The base name for the array.
//    ///   - count: The length of the array.
//    /// - Returns: An array of variables with the given base name and length.
//    static func vector(_ name: String, count: Int) -> [Variable] {
//        var arr: [Variable] = []
//        for i in 0 ..< count {
//            arr.append(Variable("\(name)[\(i)]"))
//        }
//        return arr
//    }
//
//    /// Construct a matrix (really a doubly nested array) of variables with the given base name.
//    /// - Parameters:
//    ///   - name: The base name for the matrix.
//    ///   - rows: The number of rows of variables.
//    ///   - cols: The number of columns of variables.
//    /// - Returns: The double nested  list of variables.
//    static func matrix(_ name: String, rows: Int, cols: Int) -> [[Variable]] {
//        var arrs: [[Variable]] = []
//        for i in 0 ..< rows {
//            var arr: [Variable] = []
//            for j in 0 ..< cols {
//                arr.append(Variable("\(name)[\(i),\(j)]"))
//            }
//            arrs.append(arr)
//        }
//        return arrs
//    }
// }
//
// public extension Array where Array.Element == [Variable] {
//    subscript(_ row: Int, _ col: Int) -> Variable {
//        return self[row][col]
//    }
// }
