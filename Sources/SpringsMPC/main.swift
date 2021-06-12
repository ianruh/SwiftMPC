// Created 2020 github @ianruh

import LASwift

var mpc = SpringsMPC()
mpc.numTimeHorizonSteps = 30

try mpc.codeGen(toFile: "/Users/ianruh/Dev/SwiftMPC/Sources/SpringsMPC/SpringsNumericObjectiveExtension.swift")

// let (min, pt) = try mpc.runNumeric()
// let (min, pt) = try mpc.runSymbolic()

// print("Minimum: \(min)")
// print("Point: \(pt)")
