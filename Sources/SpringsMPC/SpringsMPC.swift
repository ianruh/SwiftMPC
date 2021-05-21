import LASwift
import Minimization
import Collections
import SymbolicMath

struct SpringsMPC {
    var numTimeHorizonSteps: Int = 10
    var dt: Double = 0.1
    var maximumForce: Double = 0.5

    var initialPositionSymbolicParameters: [Parameter]? = nil
    var initialVelocitySymbolicParameters: [Parameter]? = nil

    var solver = InequalitySolver()

    mutating func runSymbolic() throws -> (minimum: Double, point: Vector) {
        
        let objective = try self.constructSymbolicObjective()

        return try self.solver.infeasibleInequalityMinimize(objective: objective)

    }

    mutating func runNumeric() throws -> (minimum: Double, point: Vector) {
        
        let objective = SpringsNumericObjective()

        return try self.solver.infeasibleInequalityMinimize(objective: objective)

    }

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

        try objective.printSwiftCode(objectiveName: "SpringsNumericObjective", parameterRepresentations: parameterRepresentations, toFile: fileName)
    }
}