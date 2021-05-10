//
// Created by Ian Ruh on 5/5/21.
//
import LASwift

///
/// Just a simple quintic objective
///
struct QuinticObjective: Objective {
    let numVariables: Int

    init(n dimensions: Int = 2) {
        self.numVariables = dimensions
    }

    func value(_ x: Vector) -> Double {
        return x.map({ $0**4 }).reduce(0, +)
    }

    func gradient(_ x: Vector) -> Vector {
        return x.map({ 4*$0**3 })
    }

    func hessian(_ x: Vector) -> Matrix {
        return diag(x.map({ 12*$0**2 }))
    }
}

///
/// Just a simple quadratic objective
///
struct QuadraticObjective: Objective {
    let numVariables: Int

    init(n dimensions: Int = 2) {
        self.numVariables = dimensions
    }

    func value(_ x: Vector) -> Double {
        return sumsq(x)
    }

    func gradient(_ x: Vector) -> Vector {
        return 2.0.*x
    }

    func hessian(_ x: Vector) -> Matrix {
        return 2.0.*eye(self.numVariables, self.numVariables)
    }
}