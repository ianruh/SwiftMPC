// Created 2020 github @ianruh

import Collections
import Foundation
import LASwift
import SwiftMPC
import SymbolicMath

struct StraightLineMPC {
    var numSteps: Int = 20
    var timeStep: Double = 0.1

    var maxAcceleration: Double = 1.0

    var solver = InequalitySolver()

    mutating func runSymbolic() throws -> (minimum: Double, point: Vector) {
        let objective = try self.symbolicObjective()

        let (min, pt, _) = try self.solver.infeasibleInequalityMinimize(objective: objective)

        return (minimum: min, point: pt)
    }

    mutating func runNumeric() throws -> (minimum: Double, point: Vector) {
        let objective = StraightLineNumericObjective()

        let (min, pt, _) = try self.solver.infeasibleInequalityMinimize(objective: objective)

        return (minimum: min, point: pt)
    }

    public func symbolicObjective() throws -> SymbolicObjective {
        let x = Variable.vector("x", count: self.numSteps)
        let v = Variable.vector("v", count: self.numSteps)

        var ordering: OrderedSet<Variable> = []
        zip(x, v).forEach { pos, vel in
            ordering.append(pos)
            ordering.append(vel)
        }

        let startingValues = ones(self.numSteps * 2)

        // Impose the max acceleration constraints
        var accelerationConstraints: [Node] = []
        for i in 0 ..< self.numSteps - 1 {
            accelerationConstraints
                .append(v[i + 1] - v[i] <= (self.maxAcceleration * self.timeStep).symbol)
        }

        // Impose the dynamics constraints
        var dynamicsConstraints: [Assign] = []
        for i in 0 ..< self.numSteps - 1 {
            dynamicsConstraints.append(x[i + 1] - x[i] ≈ v[i] * self.timeStep.symbol)
        }

        // Impose initial conditions
        dynamicsConstraints.append(x[0] ≈ 0.0)
        dynamicsConstraints.append(v[0] ≈ 0.0)

        let obj = -1 * x.last! - v.last!
        let inequalityConstraints = SymbolicVector(accelerationConstraints)
        let equalityConstraints: [Assign] = dynamicsConstraints

        guard let objective = SymbolicObjective(
            min: obj,
            subjectTo: inequalityConstraints,
            equalityConstraints: equalityConstraints,
            startPrimal: startingValues,
            ordering: ordering
        ) else {
            throw MPCError.misc("Unable to construct symbolic objective")
        }

        return objective
    }
}
