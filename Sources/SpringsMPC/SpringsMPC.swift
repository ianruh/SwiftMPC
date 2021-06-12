import LASwift
import SwiftMPC
import Collections
import SymbolicMath

struct SpringsMPC {
    var numTimeHorizonSteps: Int = 10
    var mpc_dt: Double = 0.1
    var sim_dt: Double = 0.01
    var maximumForce: Double = 0.5

    var initialPositionSymbolicParameters: [Parameter]? = nil
    var initialVelocitySymbolicParameters: [Parameter]? = nil
    var symbolicPositionMatrix: [[Variable]]? = nil
    var symbolicVelocityMatrix: [[Variable]]? = nil
    var symbolicControlMatrix: [[Variable]]? = nil

    var costs: [Double] = []

    var solver = InequalitySolver()
    var simulator = SpringsSimulator()
    var numericObjective = SpringsNumericObjective()

    // mutating func runSimulation(length: Double = 10) throws -> (positions: [Vector], velocities: [Vector], times: [Double]) {
    //     let N = Int(length / self.sim_dt)

    //     // Main simulation loop
    //     for i in 0..<N {
    //         print("Simulation step \(i)            Time: \(Double(i)*self.sim_dt)")

    //         let (min, primal, dual) = try solver.infeasibleInequalityMinimize(objective: self.numericObjective)

    //         let controlInputs: Matrix = numericObjective.extractMatrix_control(primal)
    //         let firstControlInputs: Vector = controlInputs[col: 0]

    //         self.simulator.evolve(controls: firstControlInputs)
    //         self.costs.append(self.numericObjective.value(primal))

    //         // Set the warm starts
    //         self.numericObjective.warmStartPrimal = primal
    //         self.numericObjective.warmStartDual = dual
    //     }

    //     return (positions: self.simulator.positionHistory, velocities: self.simulator.velocityHistory, times: self.simulator.timeHistory)

    // }

    /// Generate the numeric objective code
    ///
    /// - Parameter fileName: The file to write the generated code to
    /// - Throws: If the code could not be generated or the file could not be written.
    mutating func codeGen(toFile fileName: String) throws {
        let objective = try self.constructSymbolicObjective()

        var parameterRepresentations: Dictionary<Parameter, String> = [:]

        for i in 0..<6 {
            if let initialPosition = self.initialPositionSymbolicParameters {
                parameterRepresentations[initialPosition[i]] = "self.initialPosition[\(i)]"
            }
            if let initialVelocity = self.initialVelocitySymbolicParameters {
                parameterRepresentations[initialVelocity[i]] = "self.initialVelocity[\(i)]"
            }
        }

        // Construct the extractors
        let matrixExtractors: Dictionary<String, [[Variable]]> = [
            "position": self.symbolicPositionMatrix!,
            "velocity": self.symbolicVelocityMatrix!,
            "control": self.symbolicControlMatrix!
        ]

        try objective.printSwiftCode(objectiveName: "SpringsNumericObjective", parameterRepresentations: parameterRepresentations, matrixExtractors: matrixExtractors, toFile: fileName)
    }

    mutating func runSymbolic() throws -> (minimum: Double, point: Vector) {
        let objective = try self.constructSymbolicObjective()
        let (min, pt, _) = try self.solver.infeasibleInequalityMinimize(objective: objective)
        return (minimum: min, point: pt)
    }

    // mutating func runNumeric() throws -> (minimum: Double, point: Vector) {
    //     let objective = SpringsNumericObjective()
    //     let (min, pt, _) = try self.solver.infeasibleInequalityMinimize(objective: objective)
    //     return (minimum: min, point: pt)
    // }
}