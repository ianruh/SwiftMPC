import LASwift
import Minimization
import RealModule

struct LTVNumericObjective {
    // Objective properties
    var numTimeHorizonSteps: Int

    // Initial state parameters
    var initialXPosition: Double
    var initialYPosition: Double
    var initialVehicleAngle: Double
    var initialForwardVelocity: Double

    // Previous state & control parameters
    var previousVelocity: Vector
    var previousAngle: Vector
    var previousSteeringAngle: Vector

    var warmStartPrimal: Vector? = nil
    var warmStartDual: Vector? = nil

    init(numSteps: Int) {
        self.numTimeHorizonSteps = numSteps

        // Initialize the parameters
        self.initialXPosition = 0.0
        self.initialYPosition = 0.0
        self.initialVehicleAngle = 0.0
        self.initialForwardVelocity = 0.0

        self.previousVelocity = zeros(numSteps)
        self.previousAngle = zeros(numSteps)
        self.previousSteeringAngle = zeros(numSteps)
    }

    func startPoint() throws -> (primal: Vector, dual: Vector) {
        #if !NO_NUMERIC_OBJECTIVE
        var primal = zeros(self.numVariables)
        var dual = zeros(self.equalityConstraintMatrix!.rows)
        #else
        var primal = zeros(1)
        var dual = zeros(1)
        #endif

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
