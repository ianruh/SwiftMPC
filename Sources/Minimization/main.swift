import LASwift
import Numerics
import SymbolicMath
import Foundation

let x = Variable("x")
let y = Variable("y")
let z = Variable("z")

let obj = x**2 + y**2 + z**2
let constraints: SymbolicVector = [
    1.0 - y,
    5.0 - z
]
let equalityConstraintMatrix = Matrix([[1.0, 0.0, 0.0]])
let equalityConstraintVector = [1.0]

guard let objective = SymbolicObjective(min: obj, subjectTo: constraints, equalityMatrix: equalityConstraintMatrix, equalityVector: equalityConstraintVector) else {
    print("Unable to construct symbolic objective")
    exit(0)
}

var solver = InequalitySolver()
let (min, pt) = try solver.infeasibleInequalityMinimize(
        objective: objective,
        startPoint: [10.0, 10.0, 10.0])

