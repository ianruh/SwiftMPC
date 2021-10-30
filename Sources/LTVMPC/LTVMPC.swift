// Created 2020 github @ianruh

import Collections
import LASwift
import RealModule
import SwiftMPC
import SymbolicMath

public struct LTVMPC {
    var numTimeHorizonSteps: Int
    var mpc_dt: Double
    public let maxSteeringAngle: Double = 2.0 * Double.pi / 6.0
    public let maxAcceleration: Double = 1.0
    public let minAcceleration: Double = -3.0

    // Parameter and variable storage. A bit ugly, but whatever
    var parameters: [String: Parameter] = [:]
    var parameterVectors: [String: [Parameter]] = [:]
    var parameterMatrices: [String: [[Parameter]]] = [:]
    var variables: [String: Variable] = [:]
    var variableVectors: [String: [Variable]] = [:]
    var variableMatrices: [String: [[Variable]]] = [:]

    // Vehicle propertes
    let wheelBaseLength: Double = 1.0 // meters

    var solver: InequalitySolver
    var numericObjective: LTVNumericObjective

    public init(numSteps: Int, dt: Double = 0.1) {
        self.numTimeHorizonSteps = numSteps
        self.mpc_dt = dt
        self.solver = InequalitySolver()
        self.numericObjective = LTVNumericObjective(numSteps: numSteps)
    }

    public mutating func getNextControls() throws -> (acceleration: Double, steeringAngle: Double) {
        // Solve the optimization problem
        let (min, primal, dual) = try solver
            .infeasibleInequalityMinimize(objective: self.numericObjective)

        // Extract the control and relavent state variables
        let accelerationVector = LTVNumericObjective.extractVector_acceleration(primal)
        let steeringAngleVector = LTVNumericObjective.extractVector_steeringAngle(primal)
        let velocityVector = LTVNumericObjective.extractVector_forwardVelocity(primal)
        let vehicleAngleVector = LTVNumericObjective.extractVector_vehicleAngle(primal)

        // Save the vectors that the objective needs as parameters
        self.numericObjective.previousVelocity = velocityVector
        self.numericObjective.previousAngle = vehicleAngleVector
        self.numericObjective.previousSteeringAngle = steeringAngleVector

        // Set the warm starts
        // TODO: Ignoring warmstarts for now. Revist later
        // self.numericObjective.warmStartPrimal = primal
        // self.numericObjective.warmStartDual = dual

        return (acceleration: accelerationVector[0], steeringAngle: steeringAngleVector[0])
    }

    public mutating func setInitialState(
        x: Double,
        y: Double,
        vehicleAngle: Double,
        velocity: Double
    ) {
        self.numericObjective.initialXPosition = x
        self.numericObjective.initialYPosition = y
        self.numericObjective.initialVehicleAngle = vehicleAngle
        self.numericObjective.initialForwardVelocity = velocity
    }

    /// Generate the numeric objective code
    ///
    /// - Parameter fileName: The file to write the generated code to
    /// - Throws: If the code could not be generated or the file could not be written.
    public mutating func codeGen(toFile fileName: String) throws {
        let objective = try self.constructSymbolicObjective()

        var parameterRepresentations: [Parameter: String] = [:]

        for (parameterName, parameter) in self.parameters {
            parameterRepresentations[parameter] = "self.\(parameterName)"
        }
        for (parameterVectorName, parameterVector) in self.parameterVectors {
            for i in 0 ..< parameterVector.count {
                parameterRepresentations[parameterVector[i]] = "self.\(parameterVectorName)[\(i)]"
            }
        }

        // Construct the extractors
        let vectorExtractors: [String: [Variable]] = [
            "xPosition": self.variableVectors["xPosition"]!,
            "yPosition": self.variableVectors["yPosition"]!,
            "vehicleAngle": self.variableVectors["vehicleAngle"]!,
            "forwardVelocity": self.variableVectors["forwardVelocity"]!,
            "steeringAngle": self.variableVectors["steeringAngle"]!,
            "acceleration": self.variableVectors["acceleration"]!,
        ]

        try objective.printSwiftCode2(
            objectiveName: "LTVNumericObjective",
            parameterRepresentations: parameterRepresentations,
            vectorExtractors: vectorExtractors,
            toFile: fileName
        )
    }

    public mutating func runSymbolic() throws -> (minimum: Double, point: Vector) {
        let objective = try self.constructSymbolicObjective()
        let (min, pt, _) = try self.solver.infeasibleInequalityMinimize(objective: objective)
        return (minimum: min, point: pt)
    }

    #if !NO_NUMERIC_OBJECTIVE
    public mutating func runNumeric() throws -> (minimum: Double, point: Vector) {
        let objective = LTVNumericObjective(numSteps: self.numTimeHorizonSteps)
        let (min, pt, _) = try self.solver.infeasibleInequalityMinimize(objective: objective)
        return (minimum: min, point: pt)
    }
    #endif
}
