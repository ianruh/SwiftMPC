// Created 2020 github @ianruh

import Collections
import LASwift

public class SymbolicVector: Collection, ExpressibleByArrayLiteral {
    public typealias Element = Node
    public typealias Index = Int

    public var startIndex: Index { return self.elements.startIndex }
    public var endIndex: Index { return self.elements.endIndex }

    /// Whether the vector has already been simplified. Used to prevent redundant traversals of all the node trees.
    internal var isSimplified: Bool = false

    /// The nodes  that constitute the symbolic vector.
    public var elements: [Node] = []

    /// The ording of the variables of the vector. The elements of the vector inherit this ordering.
    public var orderedVariables: OrderedSet<Variable> {
        if let ordering = self._ordering {
            return ordering
        } else {
            self._ordering = OrderedSet<Variable>(self.variables.sorted())
            return self._ordering!
        }
    }

    private var _ordering: OrderedSet<Variable>?

    /// The union of all the variables in the indvidual elements of the vector.
    public lazy var variables: Set<Variable> = {
        self.elements.reduce(Set<Variable>()) { currentSet, nextElement in
            currentSet.union(nextElement.variables)
        }
    }()

    /// The union of all the parameters in the individual elements of the vector.
    public lazy var parameters: Set<Parameter> = {
        self.reduce(Set<Parameter>()) { currentSet, nextElement in
            currentSet.union(nextElement.parameters)
        }
    }()

    /// The union of all the binary variables in the individual elements of the vector.
    public lazy var binaryVariables: Set<BinaryVariable> = {
        self.reduce(Set<BinaryVariable>()) { currentSet, nextElement in
            currentSet.union(nextElement.binaryVariables)
        }
    }()


    /// Initialize a symbolic vector from an  array of nodes.
    /// - Parameter array: An array of nodes.
    public init(_ array: [Node]) {
        self.elements = array
    }

    /// Initialize a symbolic vector from an array literal of nodes.
    /// - Parameter arrayLiteral: Array litteral of  nodes.
    public required convenience init(arrayLiteral: Element...) {
        self.init(arrayLiteral)
    }

    /// Evaluate the symbolic vector using the given values for variables and parameters
    /// - Parameter values: The  values for the variables and parameters to evaulate at  (all other nodes are ignored)
    /// - Throws: If not all parameters or variables present has an associated value in `values`.
    /// - Returns: The vector representing the value of the symbolic vector.
    public func evaluate(withValues values: [Node: Double]) throws -> Vector {
        return try self.map { try $0.evaluate(withValues: values) }
    }

    /// Evaluate the symbolic vector using a vector of variable values (in the order of the vector's `orderedVariables`) and a dict of parameter values.
    /// - Parameters:
    ///   - x: A vector of values for each variable  (in the order of the vector's `orderedVariables`).
    ///   - parameterValues: The values for each parameter.
    /// - Throws: If not all  parameters or variables have values.
    /// - Returns: The vector representing the symbolic vector.
    public func evaluate(_ x: Vector,
                         withParameters parameterValues: [Parameter: Double] = [:]) throws -> Vector
    {
        // Ensure the vector is the right length
        guard x.count == self.orderedVariables.count else {
            throw SymbolicMathError
                .misc(
                    "Vector \(x) is the wrong length (\(x.count) != \(self.orderedVariables.count)"
                )
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
        return self.elements[i]
    }

    public func index(after i: Index) -> Index {
        return self.elements.index(after: i)
    }

    /// Set the variable ordering of the vector.
    /// - Parameter newOrdering: The ordering of the vector.
    /// - Throws: If not all variables in the vector are included in the ordering.
    ///
    /// More variables than are present in the vector may be  supplied
    public func setVariableOrder<C>(_ newOrdering: C) throws where C: Collection,
        C.Element == Variable
    {
        self._ordering = OrderedSet<Variable>(newOrdering)

        // The setting of the elements checks for every variable being present
        // no need to do it here too.

        // Every child element should also have it's ordering set
        for i in 0 ..< self.count {
            try self.elements[i].setVariableOrder(newOrdering)
        }
    }

    /// Simplify the vector. Does an element wise simplification of each node in the vector.
    /// - Returns: The symplified vector.
    ///
    /// This  is a very intensive operation and should only be called in non-time-sensitive operations.
    public func simplify() -> SymbolicVector {
        if self.isSimplified { return self }

        var new: SymbolicVector = [0.0].symbolic
        if self.elements.count > 20 {
            new = SymbolicVector(self.elements.parallelMap { $0.simplify() })
        } else {
            new = SymbolicVector(self.elements.map { $0.simplify() })
        }

        // let new = SymbolicVector(self.elements.map({ $0.simplify() }))

        try! new.setVariableOrder(self.orderedVariables)
        new.isSimplified = true
        return new
    }
}

public extension Vector {
    /// Constructs a symbolic form of the vector by making a symbolic vector consisting of a `Number` with each element's value.
    var symbolic: SymbolicVector {
        return SymbolicVector(self.map { Number($0) })
    }
}
