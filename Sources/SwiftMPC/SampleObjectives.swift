//
// Created by Ian Ruh on 5/5/21.
//
import LASwift
import SymbolicMath

///
/// Just a simple quintic objective
///
public struct QuinticObjective: Objective {
    public let numVariables: Int
    public let numConstraints: Int = 0

    public let equalityConstraintMatrix: Matrix? = nil
    public let equalityConstraintVector: Vector? = nil

    public init(n dimensions: Int = 2) {
        self.numVariables = dimensions
    }

    public func startPoint() -> (primal: Vector, dual: Vector) {
        return (primal: zeros(self.numVariables), dual: zeros(0))
    }

    public func value(_ x: Vector) -> Double {
        return x.map({ $0**4 }).reduce(0, +)
    }

    public func gradient(_ x: Vector) -> Vector {
        return x.map({ 4*$0**3 })
    }

    public func hessian(_ x: Vector) -> Matrix {
        return diag(x.map({ 12*$0**2 }))
    }
}

///
/// Just a simple quadratic objective
///
public struct QuadraticObjective: Objective {
    public let numVariables: Int
    public let numConstraints: Int = 0

    public let equalityConstraintMatrix: Matrix? = nil
    public let equalityConstraintVector: Vector? = nil

    public init(n dimensions: Int = 2) {
        self.numVariables = dimensions
    }

    public func startPoint() -> (primal: Vector, dual: Vector) {
        return (primal: zeros(self.numVariables), dual: zeros(0))
    }

    public func value(_ x: Vector) -> Double {
        return sumsq(x)
    }

    public func gradient(_ x: Vector) -> Vector {
        return 2.0.*x
    }

    public func hessian(_ x: Vector) -> Matrix {
        return 2.0.*eye(self.numVariables, self.numVariables)
    }
}