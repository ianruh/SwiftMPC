// Created 2020 github @ianruh

import Foundation
import LASwift
import RealModule
import SymbolicMath

precedencegroup ExponentiationPrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}

// infix operator ** : ExponentiationPrecedence

public func ** (_ base: Double, _ exp: Double) -> Double {
    return Double.pow(base, exp)
}

public func norm(_ a: Vector) -> Double {
    return sumsq(a).squareRoot()
}

@usableFromInline
internal func printDebug(_ msg: Any, file: StaticString = #file, line: UInt = #line) {
    #if !NO_PRINT
    print("\(file):\(line) --- \(msg)")
    #endif
}

// Pointwise comparisons
public func .<= (_ lhs: Double, _ rhs: Vector) -> Bool {
    return rhs.reduce(true) { currentStatus, nextElement in
        currentStatus && lhs <= nextElement
    }
}

public func .<= (_ lhs: Vector, _ rhs: Double) -> Bool {
    return lhs.reduce(true) { currentStatus, nextElement in
        currentStatus && nextElement <= rhs
    }
}

public func .>= (_ lhs: Double, _ rhs: Vector) -> Bool {
    return rhs.reduce(true) { currentStatus, nextElement in
        currentStatus && lhs >= nextElement
    }
}

public func .>= (_ lhs: Vector, _ rhs: Double) -> Bool {
    return lhs.reduce(true) { currentStatus, nextElement in
        currentStatus && nextElement >= rhs
    }
}

// Nil pointwise comparisons
public func .<= (_ lhs: Vector, _ rhs: [Double?]?) -> Bool {
    guard let right = rhs else {
        return true
    }
    guard lhs.count == right.count else {
        return false
    }
    return zip(lhs, right).reduce(true) { currentStatus, nextElement in
        let (nextElementLeft, nextElementRight) = nextElement
        return currentStatus && (nextElementRight == nil || nextElementLeft <= nextElementRight!)
    }
}

public func .<= (_ lhs: [Double?]?, _ rhs: Vector) -> Bool {
    guard let left = lhs else {
        return true
    }
    guard rhs.count == left.count else {
        return false
    }
    return zip(left, rhs).reduce(true) { currentStatus, nextElement in
        let (nextElementLeft, nextElementRight) = nextElement
        return currentStatus && (nextElementLeft == nil || nextElementLeft! <= nextElementRight)
    }
}

// Matrix
public extension Matrix {
    /// A string describing the sparsity pattern of the matrix.
    var sparsityString: String {
        var str: String = ""

        // First line
        str += "┌\(" " * self.cols)┐\n"
        for row in self {
            str += "│"
            for el in row {
                if el == 0 {
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
}

public func * (_ lhs: String, _ rhs: Int) -> String {
    var str = ""
    for _ in 0 ..< rhs {
        str += lhs
    }
    return str
}

public func .== (_ lhs: Vector, _ rhs: Double) -> Bool {
    return lhs.reduce(true) { currentStatus, nextElement in
        currentStatus && nextElement == rhs
    }
}

public func .== (_ lhs: Double, _ rhs: Vector) -> Bool {
    return rhs.reduce(true) { currentStatus, nextElement in
        currentStatus && nextElement == lhs
    }
}
