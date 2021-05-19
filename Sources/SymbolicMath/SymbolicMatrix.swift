//
// Created by Ian Ruh on 5/10/21.
//

import LASwift
import Collections

public struct SymbolicMatrix: Collection, ExpressibleByArrayLiteral, VariableOrdered {
    public typealias Element = SymbolicVector
    public typealias Index = Int

    public var startIndex: Index { return self.vectors.startIndex }
    public var endIndex: Index { return self.vectors.endIndex }

    public var rows: Int {
        return self.count
    }
    public var cols: Int {
        if(self.rows == 0) {
            return 0
        } else {
            return self[0].count
        }
    }

    internal var vectors: [SymbolicVector] = []
    public var _ordering: OrderedSet<Variable>? = nil
    public var variables: Set<Variable> {
        return self.reduce(Set<Variable>(),{(currentSet, nextVector) in
            return nextVector.reduce(currentSet, {(currentSet2, nextElement) in
                return currentSet2.union(nextElement.variables)
            })
        })
    }

    public var sparsityString: String {
        var str: String = ""
        let zeroNode: Node = Number(0)

        // First line
        str += "┌\(" "*self.cols)┐\n"
        for row in self {
            str += "│"
            for el in row {
                if(el == zeroNode) {
                    str += " "
                } else {
                    str += "*"
                }
            }
            str += "│\n"
        }
        str += "└\(" "*self.cols)┘"

        return str
    }

    public init() {}

    public init(_ array: [SymbolicVector]) {
        self.vectors = array
    }

    public init(arrayLiteral: Element...) {
        self.init()
        self.vectors = arrayLiteral
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

    // every element needs to also be set
    public mutating func setVariableOrder<C>(_ newOrdering: C) where C: Collection, C.Element == Variable {

        self._ordering = OrderedSet<Variable>(newOrdering)

        for i in 0..<self.count {
            self.vectors[i].setVariableOrder(self._ordering!)
        }
    }
}