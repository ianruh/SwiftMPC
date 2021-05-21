import LASwift
import Minimization

struct SpringsNumericObjective {

    var initialPosition: Vector = [1.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    var initialVelocity: Vector = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

    func startPoint() throws -> (primal: Vector, dual: Vector) {
        return (
            primal: ones(self.numVariables).*0.3,
            dual: ones(self.equalityConstraintMatrix!.rows)
            )
    }
}