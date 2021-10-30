// Created 2020 github @ianruh

import Collections
import LASwift

/// A matrix of symbolic numbers (nodes)
public class SymbolicMatrix: Collection, ExpressibleByArrayLiteral {
    public typealias Element = SymbolicVector
    public typealias Index = Int

    public var startIndex: Index { return self.vectors.startIndex }
    public var endIndex: Index { return self.vectors.endIndex }

    /// Whether the node has already been simplified. Used to chortcircuit and avoid repeated  calls
    /// to the `simplify()` function.
    internal var isSimplified: Bool = false

    /// The number of rows in the matrix
    public var rows: Int {
        return self.count
    }

    /// The number of columns in the matrix
    public var cols: Int {
        if self.rows == 0 {
            return 0
        } else {
            return self[0].count
        }
    }

    /// An array of nodes representing the row-major form of the matrix.
    public var flat: [Node] {
        var nodes: [Node] = []
        for vector in self.vectors {
            nodes.append(contentsOf: vector.elements)
        }
        return nodes
    }

    /// The actual backing of the matrix. Each `SymbolicVector` is a row in the matrix.
    internal var vectors: [SymbolicVector]

    private var _ordering: OrderedSet<Variable>?

    /// The ording of the variables of the matrix. The elements of the matrix inherit this ordering.
    public var orderedVariables: OrderedSet<Variable> {
        if let ordering = self._ordering {
            return ordering
        } else {
            self._ordering = OrderedSet<Variable>(self.variables.sorted())
            return self._ordering!
        }
    }

    /// The union of all the variables in the indvidual elements of the matrix.
    public lazy var variables: Set<Variable> = {
        self.vectors.reduce(Set<Variable>()) { currentSet, nextVector in
            currentSet.union(nextVector.variables)
        }
    }()

    /// The union of all the parameters in the individual elements of the matrix.
    public lazy var parameters: Set<Parameter> = {
        self.vectors.reduce(Set<Parameter>()) { currentSet, nextVector in
            currentSet.union(nextVector.parameters)
        }
    }()

    /// The union of all the binary variables in the individual elements of the matrix.
    public lazy var binaryVariables: Set<BinaryVariable> = {
        self.vectors.reduce(Set<BinaryVariable>()) { currentSet, nextVector in
            currentSet.union(nextVector.binaryVariables)
        }
    }()

    /// A string shows which elements of the matrix are zero, and which  are non-zero.
    public var sparsityString: String {
        var str: String = ""
        let zeroNode: Node = Number(0)

        // First line
        str += "┌\(" " * self.cols)┐\n"
        for row in self {
            str += "│"
            for el in row {
                if el == zeroNode {
                    str += " "
                } else {
                    str += "*"
                }
            }
            str += "│\n"
        }
        str += "└\(" " * self.cols)┘"

        return str
    }

    /// Initialize the symbolic natrix from a set of symbolic vectors.
    /// - Parameter array: An array  of  symbolic vectors that form the rows of the matrix.
    public init(_ array: [SymbolicVector]) {
        self.vectors = array
    }

    /// To be perfectly honset, I'm not entriely sure how you would use this.
    /// - Parameter arrayLiteral: An array of symbolic vectors.
    public required convenience init(arrayLiteral: Element...) {
        self.init(arrayLiteral)
    }

    /// Evaluate the symbolic matrix using the given values for variables and parameters
    /// - Parameter values: The  values for the variables and parameters to evaulate at  (all other nodes are ignored)
    /// - Throws: If not all parameters or variables present has an associated value in `values`.
    /// - Returns: The matrix representing the value of the symbolic matrix.
    public func evaluate(withValues values: [Node: Double]) throws -> Matrix {
        guard self.count != 0 else {
            throw SymbolicMathError.misc("Cannot evaluate empty symbolic matrix")
        }

        // Check that all vectors are the same length
        for el in self {
            guard el.count == self.first!.count else {
                throw SymbolicMathError.misc("Vectors are different lengths")
            }
        }

        var matrixValues: Vector = []

        for vec in self {
            for el in vec {
                try matrixValues.append(el.evaluate(withValues: values))
            }
        }

        return Matrix(self.count, self.first!.count, matrixValues)
    }

    /// Evaluate the symbolic matrix using a vector of variable values (in the order of the matrice's `orderedVariables`) and a dict of parameter values.
    /// - Parameters:
    ///   - x: A vector of values for each variable  (in the order of the matrice's `orderedVariables`).
    ///   - parameterValues: The values for each parameter.
    /// - Throws: If not all  parameters or variables have values.
    /// - Returns: The matrix representing the symbolic matrix.
    public func evaluate(_ x: Vector,
                         withParameters parameterValues: [Parameter: Double] = [:]) throws -> Matrix
    {
        // Ensure the vector is the right length
        guard x.count == self.orderedVariables.count else {
            throw SymbolicMathError
                .misc("Vector \(x) is the wrong length (\(x.count) != \(self.variables.count)")
        }

        // We don't check that all parameters are represented. It will throw a clear error if one is missing when
        // it tries to evaluate it.

        var values = [Node: Double]()
        let orderedVariables = self.orderedVariables
        for i in 0 ..< x.count {
            values[orderedVariables[i]] = x[i]
        }

        // merge in the parameters. The closure is meaningless, as there will never be conflicting
        // keys in this case (only variables present in values, and only parameters present in
        // parameterValues).
        values.merge(parameterValues, uniquingKeysWith: { current, _ in current })

        return try self.evaluate(withValues: values)
    }

    public subscript(i: Index) -> Element {
        return self.vectors[i]
    }

    public subscript(_ row: Int, _ col: Int) -> Node {
        return self.vectors[row][col]
    }

    public func index(after i: Index) -> Index {
        return self.vectors.index(after: i)
    }

    /// Set the variable ordering of the matrix.
    /// - Parameter newOrdering: The ordering of the matrix.
    /// - Throws: If not all variables in the matrix are included in the ordering.
    ///
    /// More variables than are present in the matrix may be  supplied
    public func setVariableOrder<C>(_ newOrdering: C) throws where C: Collection,
        C.Element == Variable
    {
        self._ordering = OrderedSet<Variable>(newOrdering)

        // The elements set ordering will throw if there is a missing variable, so no need to
        // check here as well

        for i in 0 ..< self.count {
            try self.vectors[i].setVariableOrder(self.orderedVariables)
        }
    }

    /// Simplify the matrix. Does  an element wise  simplification of each node in  the matrix.
    /// - Returns: The symplified matrix
    ///
    /// This  is a very intensive operation and should only be  called in non-time-sensitive operations.
    public func simplify() -> SymbolicMatrix {
        if self.isSimplified { return self }

        let new = SymbolicMatrix(self.vectors.parallelMap { $0.simplify() })
        try! new.setVariableOrder(self.orderedVariables)
        new.isSimplified = true
        return new
    }
}

public extension Matrix {
    /// A symbolic representation of a `Matrix`. Constructs it by converting every element into a `Number` node.
    var symbolic: SymbolicMatrix {
        var arrs: [SymbolicVector] = []
        for i in 0 ..< self.rows {
            arrs.append(SymbolicVector(self[row: i].map { Number($0) }))
        }
        return SymbolicMatrix(arrs)
    }
}
