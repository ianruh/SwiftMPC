import Foundation
import LASwift

var mpc = StraightLineMPC()
mpc.numSteps = 20
mpc.solver.hyperParameters.newtonStepsStageMaximum = 40
mpc.solver.hyperParameters.homotopyStagesMaximum = 5
mpc.solver.hyperParameters.homotopyParameterStart = 1.0

func writeNumericObjective(_ mpc: StraightLineMPC) throws {
    let objective = try mpc.symbolicObjective()

    try objective.printSwiftCode(
        objectiveName: "StraightLineNumericObjective",
        toFile: "/Users/ianruh/Dev/Minimization/Sources/StraightLineMPC/StraightLineNumericObjective.swift"    
    )
}

// writeNumericObjective(mpc)

// let (min, pt): (Double, Vector) = try mpc.runSymbolic()
let (min, pt): (Double, Vector) = try mpc.runNumeric()

print("\(pt)")