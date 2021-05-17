import Foundation
import PythonKit
import LASwift

// let plt = Python.import("matplotlib.pyplot")
// let tpl  = Python.import("termplotlib")
// let np = Python.import("numpy")

var mpc = StraightLineMPC()
mpc.numSteps = 2
mpc.solver.hyperParameters.newtonStepsStageMaximum = 100
mpc.solver.hyperParameters.homotopyStagesMaximum = 10
mpc.solver.hyperParameters.homotopyParameterStart = 1.0
let (min, pt): (Double, Vector) = try mpc.run()

print("Points: \(pt)")


// plt.plot(Array(pt[0..<4]))
// plt.title("Velocity")
// plt.show()

// plt.plot(Array(pt[4..<pt.count]))
// plt.title("Position")
// plt.show()