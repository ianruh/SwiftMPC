// Created 2020 github @ianruh

import Collections
import LASwift
import RealModule
import SwiftMPC
import SymbolicMath

/// Implementation of on of the examples from https://web.stanford.edu/~boyd/papers/fast_mpc.html
public extension LTVMPC {
    mutating func constructSymbolicObjective() throws -> SymbolicObjective {
        //======== State Variables ========

        // These are a N length vectors, with each element representing points in time
        let xPosition = Variable.vector("x", count: self.numTimeHorizonSteps)
        let yPosition = Variable.vector("y", count: self.numTimeHorizonSteps)
        let vehicleAngle = Variable.vector("θ", count: self.numTimeHorizonSteps)
        let forwardVelocity = Variable.vector("vf", count: self.numTimeHorizonSteps)

        // Save the state variable
        self.variableVectors["xPosition"] = xPosition
        self.variableVectors["yPosition"] = yPosition
        self.variableVectors["vehicleAngle"] = vehicleAngle
        self.variableVectors["forwardVelocity"] = forwardVelocity

        //======== Control Variables ========

        let steerigAngle = Variable.vector("δ", count: self.numTimeHorizonSteps)
        let acceleration = Variable.vector("a", count: self.numTimeHorizonSteps)

        // Note: We are letting acceleration be true acceleration here, rather
        // than throttle. Apart from motor dynamics, the biggest difference
        // is that a negative throttle does jack. We will need to add another
        // control variable for braking (or maybe infer that control from a
        // negative acceleration?)

        // Save the control variables
        self.variableVectors["steeringAngle"] = steerigAngle
        self.variableVectors["acceleration"] = acceleration

        //======== Variable Ordering ========

        // ORDER MATTERS, A LOT!!!
        var ordering: OrderedSet<Variable> = []
        for t in 0 ..< self.numTimeHorizonSteps {
            ordering.append(xPosition[t])
            ordering.append(yPosition[t])
            ordering.append(vehicleAngle[t])
            ordering.append(forwardVelocity[t])
            ordering.append(steerigAngle[t])
            ordering.append(acceleration[t])
        }

        //======== Parameters ========

        // Initial Postion Parameters
        let initialXPosition = Parameter("x₀")
        let initialYPosition = Parameter("y₀")
        let initialVehicleAngle = Parameter("θ₀")
        let initialForwardVelocity = Parameter("vf₀")

        // Previous iteration state and control variables. These are used to linearize
        // the dynamics around approximately the correct points.
        let previousVelocity = Parameter.vector("vf_prev", count: self.numTimeHorizonSteps)
        let previousAngle = Parameter.vector("θ_prev", count: self.numTimeHorizonSteps)
        let previousSteeringAngle = Parameter.vector("δ_prev", count: numTimeHorizonSteps)

        // Save the parameters
        self.parameters["initialXPosition"] = initialXPosition
        self.parameters["initialYPosition"] = initialYPosition
        self.parameters["initialVehicleAngle"] = initialVehicleAngle
        self.parameters["initialForwardVelocity"] = initialForwardVelocity

        self.parameterVectors["previousVelocity"] = previousVelocity
        self.parameterVectors["previousAngle"] = previousAngle
        self.parameterVectors["previousSteeringAngle"] = previousSteeringAngle

        // Set symbolic initial values. Not used when using the code generated objective
        var initialParameterValues: [Parameter: Double] = [:]
        initialParameterValues[initialXPosition] = 0.0
        initialParameterValues[initialYPosition] = 0.0
        initialParameterValues[initialVehicleAngle] = 0.0
        initialParameterValues[initialForwardVelocity] = 0.0
        previousVelocity.forEach { initialParameterValues[$0] = 0.0 }
        previousAngle.forEach { initialParameterValues[$0] = 0.0 }
        previousSteeringAngle.forEach { initialParameterValues[$0] = 0.0 }

        //================ Constraints ================

        var ineqConstraints: [Node] = []
        var eqConstraints: [Assign] = []

        //======== Misc Constraints ========

        // Initial conditions
        eqConstraints.append(xPosition[0] ≈ initialXPosition)
        eqConstraints.append(yPosition[0] ≈ initialYPosition)
        eqConstraints.append(vehicleAngle[0] ≈ initialVehicleAngle)
        eqConstraints.append(forwardVelocity[0] ≈ initialForwardVelocity)

        // Control variable constraints
        for t in 0 ..< self.numTimeHorizonSteps {
            ineqConstraints.append(steerigAngle[t] <= self.maxSteeringAngle)
            ineqConstraints.append(steerigAngle[t] >= -1 * self.maxSteeringAngle)
            ineqConstraints.append(acceleration[t] <= self.maxAcceleration)
            ineqConstraints.append(acceleration[t] >= self.minAcceleration)
        }

        //======== Dynamics Constraints ========

        // Position and Velcoity
        for t in 1 ..< self.numTimeHorizonSteps {
            // X Position constraint
            eqConstraints
                .append(xPosition[t] ≈ xPosition[t - 1] + self
                    .mpc_dt * previousVelocity[t] *
                    (Cos(vehicleAngle[t - 1] + previousSteeringAngle[t])
                        .taylorExpand(in: vehicleAngle[t - 1], about: previousAngle[t], ofOrder: 1)!))
            // Y Position Constraint
            eqConstraints
                .append(yPosition[t] ≈ yPosition[t - 1] + self
                    .mpc_dt * previousVelocity[t] *
                    (Sin(vehicleAngle[t - 1] + previousSteeringAngle[t])
                        .taylorExpand(in: vehicleAngle[t - 1], about: previousAngle[t], ofOrder: 1)!))
            // Angular Constraint
            eqConstraints
                .append(vehicleAngle[t] ≈ vehicleAngle[t - 1] + self
                    .mpc_dt * previousVelocity[t] * (1.0 / self.wheelBaseLength) *
                    (Sin(steerigAngle[t - 1])
                        .taylorExpand(in: steerigAngle[t - 1], about: previousSteeringAngle[t], ofOrder: 1)!))
            // Velocity Constraint
            eqConstraints.append(forwardVelocity[t] ≈ forwardVelocity[t - 1] + self.mpc_dt * acceleration[t - 1])
        }

        //======== Objective ========

        let objectiveNode: Node = -1 * xPosition.last! + -1 * forwardVelocity.last!

        guard let objective = SymbolicObjective(
            min: objectiveNode,
            subjectTo: SymbolicVector(ineqConstraints),
            equalityConstraints: eqConstraints,
            ordering: ordering,
            parameterValues: initialParameterValues
        ) else {
            throw MPCError.misc("Unable to construct symbolic objective")
        }

        return objective
    }
}
