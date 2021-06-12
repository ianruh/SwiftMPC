// Created 2020 github @ianruh

import Collections
import LASwift

public class SymbolicVector: Collection, ExpressibleByArrayLiteral {
    public typealias Element = Node
    public typealias Index = Int

    public var startIndex: Index { return self.elements.startIndex }
    public var endIndex: Index { return self.elements.endIndex }

    internal var isSimplified: Bool = false

    public var elements: [Node] = []

    private var _ordering: OrderedSet<Variable>?
    public var orderedVariables: OrderedSet<Variable> {
        if let ordering = self._ordering {
            return ordering
        } else {
            self._ordering = OrderedSet<Variable>(self.variables.sorted())
            return self._ordering!
        }
    }

    public lazy var variables: Set<Variable> = {
        self.elements.reduce(Set<Variable>()) { currentSet, nextElement in
            currentSet.union(nextElement.variables)
        }
    }()

    public lazy var parameters: Set<Parameter> = {
        self.reduce(Set<Parameter>()) { currentSet, nextElement in
            currentSet.union(nextElement.parameters)
        }
    }()

    public init(_ array: [Node]) {
        self.elements = array
    }

    public required convenience init(arrayLiteral: Element...) {
        self.init(arrayLiteral)
    }

    public func evaluate(withValues values: [Node: Double]) throws -> Vector {
        return try self.map { try $0.evaluate(withValues: values) }
    }

    public func evaluate(_ x: Vector, withParameters parameterValues: [Parameter: Double] = [:]) throws -> Vector {
        // Ensure the vector is the right length
        guard x.count == self.orderedVariables.count else {
            throw SymbolicMathError
                .misc("Vector \(x) is the wrong length (\(x.count) != \(self.orderedVariables.count)")
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

    // every element needs to also be set
    public func setVariableOrder<C>(_ newOrdering: C) throws where C: Collection, C.Element == Variable {
        self._ordering = OrderedSet<Variable>(newOrdering)

        // The setting of the elements checks for every variable being present
        // no need to do it here too.

        // Every child element should also have it's ordering set
        for i in 0 ..< self.count {
            try self.elements[i].setVariableOrder(newOrdering)
        }
    }

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
    var symbolic: SymbolicVector {
        return SymbolicVector(self.map { Number($0) })
    }
}
