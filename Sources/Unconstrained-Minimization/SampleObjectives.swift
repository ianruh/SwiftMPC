//
// Created by Ian Ruh on 5/5/21.
//
import LASwift

struct QuinticObjective: Objective {
    let numVariables: Int = 2

    func value(_ x: Vector) -> Double {
        return x[0]**4 + x[1]**4
    }

    func gradient(_ x: Vector) -> Vector {
        return [4*x[0]**3, 4*x[1]**3]
    }

    func hessian(_ x: Vector) -> Matrix {
        return Matrix([
            [12*x[0]**2, 0],
            [0, 12*x[1]**2]
        ])
    }
}

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