import LASwift

var mpc = SpringsMPC()
mpc.numTimeHorizonSteps = 20

let (positions, velocities, times) = try mpc.runSimulation()

//try mpc.codeGen(toFile: "/Users/ianruh/Dev/Minimization/Sources/SpringsMPC/SpringsNumericObjectiveExtension.swift")

//let (min, pt) = try mpc.runNumeric()
// let (min, pt) = try mpc.runSymbolic()

//print("Minimum: \(min)")
//print("Point: \(pt)")

print("Average Cost: \(mean(mpc.costs))")