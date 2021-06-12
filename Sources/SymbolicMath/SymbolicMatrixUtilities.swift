// Created 2020 github @ianruh

import LASwift
import RealModule

public extension SymbolicMatrix {
    convenience init(_ vecs: [[Variable]]) {
        self.init(vecs.map { SymbolicVector($0) })
    }
}

public func sum(_ mat: SymbolicMatrix) -> Node {
    return mat.flat.reduce(Number(0)) { currentSum, nextNode in
        currentSum + nextNode
    }.simplify()
}

public func sum(_ mat: [[Variable]]) -> Node {
    return sum(SymbolicMatrix(mat))
}

public func + (_ lhs: SymbolicMatrix, _ rhs: SymbolicMatrix) -> SymbolicMatrix {
    return SymbolicMatrix(zip(lhs.vectors, rhs.vectors).map { $0 + $1 })
}

public func .* (_ lhs: SymbolicMatrix, _ rhs: Double) -> SymbolicMatrix {
    return SymbolicMatrix(lhs.vectors.map { $0 .* rhs })
}

public func .* (_ lhs: Double, _ rhs: SymbolicMatrix) -> SymbolicMatrix {
    return SymbolicMatrix(rhs.vectors.map { $0 .* lhs })
}

public func .* (_ lhs: SymbolicMatrix, _ rhs: Node) -> SymbolicMatrix {
    return SymbolicMatrix(lhs.vectors.map { $0 .* rhs })
}

public func .* (_ lhs: Node, _ rhs: SymbolicMatrix) -> SymbolicMatrix {
    return SymbolicMatrix(rhs.vectors.map { $0 .* lhs })
}

public func .** (_ lhs: SymbolicMatrix, _ rhs: Int) -> SymbolicMatrix {
    return SymbolicMatrix(lhs.vectors.map { $0 .** rhs })
}

public func .* (_ lhs: [[Variable]], _ rhs: Double) -> SymbolicMatrix {
    return SymbolicMatrix(lhs) .* rhs
}

public func .* (_ lhs: Double, _ rhs: [[Variable]]) -> SymbolicMatrix {
    return lhs .* SymbolicMatrix(rhs)
}

public func .** (_ lhs: [[Variable]], _ rhs: Int) -> SymbolicMatrix {
    return SymbolicMatrix(lhs) .** rhs
}
