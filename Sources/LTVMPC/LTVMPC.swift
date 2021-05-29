import LASwift
import Minimization
import Collections
import SymbolicMath

struct LTVMPC {
    var numTimeHorizonSteps: Int
    var mpc_dt: Double
    let maxSteeringAngle: Double = 2.0*Double.pi/6.0
    let maxAcceleration: Double = 1.0
    let minAcceleration: Double = -3.0

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

    init(numSteps: Int, dt: Double = 0.1) {
        self.numTimeHorizonSteps = numSteps
        self.mpc_dt = dt
        self.solver = InequalitySolver()
        self.numericObjective = LTVNumericObjective(numSteps: numSteps)
    }

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

        // for i in 0..<6 {
        //     if let initialPosition = self.initialPositionSymbolicParameters {
        //         parameterRepresentations[initialPosition[i]] = "self.initialPosition[\(i)]"
        //     }
        //     if let initialVelocity = self.initialVelocitySymbolicParameters {
        //         parameterRepresentations[initialVelocity[i]] = "self.initialVelocity[\(i)]"
        //     }
        // }

        for (parameterName, parameter) in self.parameters {
            parameterRepresentations[parameter] = "self.\(parameterName)"
        }
        for (parameterVectorName, parameterVector) in self.parameterVectors {
            for i in 0..<parameterVector.count {
                parameterRepresentations[parameterVector[i]] = "self.\(parameterVectorName)[\(i)]"
            }
        }

        // Construct the extractors
        let vectorExtractors: Dictionary<String, [Variable]> = [
            "xPosition": self.variableVectors["xPosition"]!,
            "yPosition": self.variableVectors["yPosition"]!,
            "vehicleAngle": self.variableVectors["vehicleAngle"]!,
            "forwardVelocity": self.variableVectors["forwardVelocity"]!,
            "steeringAngle": self.variableVectors["steeringAngle"]!,
            "acceleration": self.variableVectors["acceleration"]!
        ]

        try objective.printSwiftCode(objectiveName: "LTVNumericObjective", parameterRepresentations: parameterRepresentations, vectorExtractors: vectorExtractors, toFile: fileName)
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