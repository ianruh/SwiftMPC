// Created 2020 github @ianruh

import LASwift
import RealModule

/// Take an elementwise sum of the nodes  in the vector.
/// - Parameter vec: The vector to sum.
/// - Returns: The node representing the sum of each element in the vector.
public func sum(_ vec: SymbolicVector) -> Node {
    return vec.elements.reduce(Number(0)) { currentSum, nextNode in
        currentSum + nextNode
    }.simplify()
}

public func sum(_ vec: [Variable]) -> Node {
    return sum(SymbolicVector(vec))
}

public func + (_ lhs: SymbolicVector, _ rhs: SymbolicVector) -> SymbolicVector {
    return SymbolicVector(zip(lhs, rhs).map { $0 + $1 })
}

public func * (_ lhs: SymbolicVector, _ rhs: SymbolicVector) -> SymbolicMatrix {
    var rows: [SymbolicVector] = []
    for leftEl in lhs {
        var row: [Node] = []
        for rightEl in rhs {
            row.append(leftEl * rightEl)
        }
        rows.append(SymbolicVector(row))
    }
    return SymbolicMatrix(rows)
}

public func .* (_ lhs: SymbolicVector, _ rhs: Double) -> SymbolicVector {
    return SymbolicVector(lhs.elements.map { $0 * rhs })
}

public func .* (_ lhs: Double, _ rhs: SymbolicVector) -> SymbolicVector {
    return SymbolicVector(rhs.elements.map { $0 * lhs })
}

public func .* (_ lhs: SymbolicVector, _ rhs: Node) -> SymbolicVector {
    return SymbolicVector(lhs.elements.map { $0 * rhs })
}

public func .* (_ lhs: Node, _ rhs: SymbolicVector) -> SymbolicVector {
    return SymbolicVector(rhs.elements.map { $0 * lhs })
}

public func .** (_ lhs: SymbolicVector, _ rhs: Int) -> SymbolicVector {
    return SymbolicVector(lhs.elements.map { $0 ** Number(rhs) })
}

public func .* (_ lhs: [Variable], _ rhs: Double) -> SymbolicVector {
    return SymbolicVector(lhs) .* rhs
}

public func .* (_ lhs: Double, _ rhs: [Variable]) -> SymbolicVector {
    return lhs .* SymbolicVector(rhs)
}

public func .** (_ lhs: [Variable], _ rhs: Int) -> SymbolicVector {
    return SymbolicVector(lhs) .** rhs
}
