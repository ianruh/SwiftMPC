
var mpc = SpringsMPC()
mpc.numTimeHorizonSteps = 10

// try mpc.codeGen(toFile: "/Users/ianruh/Dev/Minimization/Sources/SpringsMPC/SpringsNumericObjectiveExtension.swift")

let (min, pt) = try mpc.runNumeric()
// let (min, pt) = try mpc.runSymbolic()

print("Minimum: \(min)")
print("Point: \(pt)")