//
// Created by Ian Ruh on 5/10/21.
//

import LASwift
import Collections

public struct SymbolicVector: Collection, ExpressibleByArrayLiteral, VariableOrdered {
    public typealias Element = Node
    public typealias Index = Int

    public var startIndex: Index { return self.elements.startIndex }
    public var endIndex: Index { return self.elements.endIndex }

    public var elements: [Node] = []
    public var _ordering: OrderedSet<Variable>? = nil
    public var variables: Set<Variable> {
        return self.reduce(Set<Variable>(),{(currentSet, nextElement) in
            return currentSet.union(nextElement.variables)
        })
    }
    public var parameters: Set<Parameter> {
        return self.reduce(Set<Parameter>(),{(currentSet, nextElement) in
            return currentSet.union(nextElement.parameters)
        })
    }

    public init() {}

    public init(_ array: [Node]) {
        self.elements = array
    }

    public init(arrayLiteral: Element...) {
        self.init()
        self.elements = arrayLiteral
    }

    public func evaluate(withValues values: [Node: Double]) throws -> Vector {
        return try self.map({ try $0.evaluate(withValues: values) })
    }

    public func evaluate(_ x: Vector, withParameters parameterValues: Dictionary<Parameter, Double> = [:]) throws -> Vector {
        // Ensure the vector is the right length
        guard x.count == self.orderedVariables.count else {
            throw SymbolicMathError.misc("Vector \(x) is the wrong length (\(x.count) != \(self.orderedVariables.count)")
        }

        // We don't check that all parameters are represented. It will throw a clear error if one is missing when
        // it tries to evaluate it.

        var values = Dictionary<Node, Double>()
        let orderedVariables = self.orderedVariables
        for i in 0..<x.count {
            values[orderedVariables[i]] = x[i]
        }

        // merge in the parameters. The closure is meaningless, as there will never be conflicting
        // keys in this case (only variables present in values, and only parameters present in 
        // parameterValues).
        values.merge(parameterValues, uniquingKeysWith: {(current, _) in current})

        return try self.evaluate(withValues: values)
    }

    public subscript(i: Index) -> Element {
        return self.elements[i]
    }

    public func index(after i: Index) -> Index {
        return self.elements.index(after: i)
    }

    // every element needs to also be set
    public mutating func setVariableOrder<C>(_ newOrdering: C) where C: Collection, C.Element == Variable {
        self._ordering = OrderedSet<Variable>(newOrdering)

        // Every child element should also have it's ordering set
        for i in 0..<self.count {
            self.elements[i].setVariableOrder(newOrdering)
        }
    }

    public func simplify() -> SymbolicVector {
        var new = SymbolicVector(self.elements.map({ $0.simplify() }))
        new.setVariableOrder(self.orderedVariables)
        return new
    }
}

public extension Vector {
    var symbolic: SymbolicVector {
        return SymbolicVector(self.map({ Number($0) }))
    }
}