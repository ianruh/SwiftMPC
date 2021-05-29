import LASwift

var mpc = LTVMPC(numSteps: 5)

try mpc.codeGen(toFile: "/Users/ianruh/Dev/Minimization/Sources/LTVMPC/LTVNumericObjectiveExtension.swift")