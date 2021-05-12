//
// Created by Ian Ruh on 5/10/21.
//

import LASwift
import Collections

public struct SymbolicVector: Collection, RangeReplaceableCollection, ExpressibleByArrayLiteral, VariableOrdered {
    public typealias Element = Node
    public typealias Index = Int

    public var startIndex: Index { return self.elements.startIndex }
    public var endIndex: Index { return self.elements.endIndex }

    private var elements: [Node] = []
    public var _ordering: OrderedSet<Variable>? = nil
    public var variables: Set<Variable> {
        return self.reduce(Set<Variable>(),{(currentSet, nextElement) in
            return currentSet.union(nextElement.variables)
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

    public mutating func replaceSubrange<C>(_ bounds: Range<SymbolicVector.Index>, with newElements: C) where C : Collection, C.Element == Node {
        self.elements.replaceSubrange(bounds, with: newElements)
    }

    public func evaluate(withValues values: [Node: Double]) throws -> Vector {
        return try self.map({ try $0.evaluate(withValues: values) })
    }

    public func evaluate(_ x: Vector) throws -> Vector {
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
        return self.elements[i]
    }

    public func index(after i: Index) -> Index {
        return self.elements.index(after: i)
    }
}