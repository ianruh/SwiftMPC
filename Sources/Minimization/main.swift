import LASwift
import Numerics

//let min = try unconstrainedMinimize(QuinticObjective(n: 100), gradEpsilon: 1e-6, debugInfo: true)

//let equalityConstraints = Matrix([[1.0, 0]]) // x = 1, assuming starting point is 1,1
//let startPoint = [1.0, 1.0]
//let min = try equalityConstrainedMinimize(objective: QuinticObjective(n: 2), equalityConstraintMatrix: equalityConstraints, startPoint: startPoint, debugInfo: true)

let equalityConstraints = Matrix([[1.0, 0]])
let equalityConstraintVector = [2.0]
let min = try infeasibleEqualityMinimize(
        objective: QuinticObjective(n: 2),
        equalityConstraintMatrix: equalityConstraints,
        equalityConstraintVector: equalityConstraintVector,
        debugInfo: true)