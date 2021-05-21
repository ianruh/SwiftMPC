import LASwift
import Numerics

public func sum(_ vec: SymbolicVector) -> Node {
    return vec.elements.reduce(Number(0), {(currentSum, nextNode) in 
        return currentSum + nextNode
    }).simplify()
}

public func sum(_ vec: [Variable]) -> Node {
    return sum(SymbolicVector(vec))
}

public func .*(_ lhs: SymbolicVector, _ rhs: Double) -> SymbolicVector {
    return SymbolicVector(lhs.elements.map({ $0 * rhs }))
}
public func .*(_ lhs: Double, _ rhs: SymbolicVector) -> SymbolicVector {
    return SymbolicVector(rhs.elements.map({ $0 * lhs }))
}
public func .**(_ lhs: SymbolicVector, _ rhs: Double) -> SymbolicVector {
    return SymbolicVector(lhs.elements.map({ $0 ** Number(rhs) }))
}

public func .*(_ lhs: [Variable], _ rhs: Double) -> SymbolicVector {
    return SymbolicVector(lhs) .* rhs
}
public func .*(_ lhs: Double, _ rhs: [Variable]) -> SymbolicVector {
    return lhs .* SymbolicVector(rhs)
}
public func .**(_ lhs: [Variable], _ rhs: Double) -> SymbolicVector {
    return SymbolicVector(lhs) .** rhs
}