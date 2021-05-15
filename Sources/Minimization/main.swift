import LASwift
import Numerics
import SymbolicMath
import Foundation

let x = Variable("x")
let y = Variable("y")
let z = Variable("z")
guard let objective = SymbolicObjective(min: x**2 + y**2 + z**2,
        subjectTo: [
            1.0 - y,
            5.0 - z
            ] // f(x) <= 0
    ) else {
    print("Unable to construct symbolic objective")
    exit(0)
}

let equalityConstraints = Matrix([[1.0, 0.0, 0.0]])
let equalityConstraintVector = [1.0]
let solver = InequalitySolver()
let min = try solver.infeasibleInequalityMinimize(
        objective: objective,
        equalityConstraintMatrix: equalityConstraints,
        equalityConstraintVector: equalityConstraintVector,
        startPoint: [10.0, 10.0, 10.0])

