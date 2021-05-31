import LASwift
import SimpleSimulator
import Foundation

// var mpc = LTVMPC(numSteps: 30)

// try mpc.codeGen(toFile: "/Users/ianruh/Dev/Minimization/Sources/LTVMPC/LTVNumericObjectiveExtension.swift")

// let (min, pt) = try mpc.runNumeric()

// print("====== State Variables ======")
// print("X Position: \(LTVNumericObjective.extractVector_xPosition(pt))")
// print("Y Position: \(LTVNumericObjective.extractVector_yPosition(pt))")
// print("Forward Velocity: \(LTVNumericObjective.extractVector_forwardVelocity(pt))")
// print("Angle: \(LTVNumericObjective.extractVector_vehicleAngle(pt))")

// print("\n====== Control Variables ======")
// print("Steering Angle: \(LTVNumericObjective.extractVector_steeringAngle(pt))")
// print("Acceleration: \(LTVNumericObjective.extractVector_acceleration(pt))")

guard let ws = WebSocket() else {
    print("Unable to create websocket")
    exit(0)
}

Thread.sleep(forTimeInterval: 5.0)

try ws.writeString("[{'id': 'box1', 'data': {'type': 'rect'}}]")