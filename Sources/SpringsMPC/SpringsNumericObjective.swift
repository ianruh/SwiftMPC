import LASwift
import SwiftMPC

struct SpringsNumericObjective {

    var initialPosition: Vector = [1.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    var initialVelocity: Vector = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

    var warmStartPrimal: Vector? = nil
    var warmStartDual: Vector? = nil

    func startPoint() throws -> (primal: Vector, dual: Vector) {
        // var primal = ones(self.numVariables).*0.3
        // var dual = ones(self.equalityConstraintMatrix!.rows)
       var primal = ones(1)
       var dual = ones(1)

        if let warmStartPrimal = self.warmStartPrimal {
            primal = warmStartPrimal
        }
        if let warmStartDual = self.warmStartDual {
            dual = warmStartDual
        }

        return (
            primal: primal,
            dual: dual
            )
    }
}