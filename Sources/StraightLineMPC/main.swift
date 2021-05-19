import Foundation
import LASwift

var mpc = StraightLineMPC()
mpc.numSteps = 20
mpc.solver.hyperParameters.newtonStepsStageMaximum = 40
mpc.solver.hyperParameters.homotopyStagesMaximum = 5
mpc.solver.hyperParameters.homotopyParameterStart = 1.0
let (min, pt): (Double, Vector) = try mpc.run()

print("Points: \(pt)")