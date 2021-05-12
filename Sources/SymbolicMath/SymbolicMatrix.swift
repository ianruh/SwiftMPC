//
// Created by Ian Ruh on 5/10/21.
//

import LASwift
import Collections

public struct SymbolicMatrix: Collection, RangeReplaceableCollection, ExpressibleByArrayLiteral, VariableOrdered {
    public typealias Element = SymbolicVector
    public typealias Index = Int

    public var startIndex: Index { return self.vectors.startIndex }
    public var endIndex: Index { return self.vectors.endIndex }

    private var vectors: [SymbolicVector] = []
    public var _ordering: OrderedSet<Variable>? = nil
    public var variables: Set<Variable> {
        return self.reduce(Set<Variable>(),{(currentSet, nextVector) in
            return nextVector.reduce(currentSet, {(currentSet2, nextElement) in
                return currentSet2.union(nextElement.variables)
            })
        })
    }

    public init() {}

    public init(_ array: [SymbolicVector]) {
        self.vectors = array
    }

    public init(arrayLiteral: Element...) {
        self.init()
        self.vectors = arrayLiteral
    }

    public mutating func replaceSubrange<C>(_ bounds: Range<SymbolicVector.Index>, with newElements: C) where C : Collection, C.Element == SymbolicVector {
        self.vectors.replaceSubrange(bounds, with: newElements)
    }

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

    public func evaluate(_ x: Vector) throws -> Matrix {
        // Ensure the vector is the right length
        guard x.count == self.orderedVariables.count else {
            throw SymbolicMathError.misc("Vector \(x) is the wrong length (\(x.count) != \(self.variables.count)")
        }

        var values = Dictionary<Node, Double>()
        let orderedVariables = self.orderedVariables
        for i in 0..<x.count {
            values[orderedVariables[i]] = x[i]
        }
        return try self.evaluate(withValues: values)
    }

    public subscript(i: Index) -> Element {
        return self.vectors[i]
    }

    public func index(after i: Index) -> Index {
        return self.vectors.index(after: i)
    }
}