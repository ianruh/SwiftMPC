import LASwift
import Collections
import SwiftMPC
import SymbolicMath

/// Implementation of on of the examples from https://web.stanford.edu/~boyd/papers/fast_mpc.html
extension SpringsMPC {
    public mutating func constructSymbolicObjective() throws -> SymbolicObjective {
        //==== State Variables ====
        // These is a 6xN matrix, with columns representing points in time
        let x = Variable.matrix("x", rows: 6, cols: self.numTimeHorizonSteps)
        let v = Variable.matrix("v", rows: 6, cols: self.numTimeHorizonSteps)
        let a = Variable.matrix("a", rows: 6, cols: self.numTimeHorizonSteps)
        // Save the state variable
        self.symbolicPositionMatrix = x
        self.symbolicVelocityMatrix = v

        //==== Control Variables ====
        let u = Variable.matrix("u", rows: 3, cols: self.numTimeHorizonSteps)
        // Save the control variables
        self.symbolicControlMatrix = u

        //==== Variable Ordering ====
        var ordering: OrderedSet<Variable> = []
        for t in 0..<self.numTimeHorizonSteps {
            for mass in 0..<6 {
                ordering.append(x[mass, t])
                ordering.append(v[mass, t])
                ordering.append(a[mass, t])
            }
            ordering.append(u[0, t])
            ordering.append(u[1, t])
            ordering.append(u[2, t])
        }

        //==== Parameters ====
        let initialPosition = Parameter.vector("xi", count: 6)
        let initialVelocity = Parameter.vector("vi", count: 6)
        // Save the parameters
        self.initialPositionSymbolicParameters = initialPosition
        self.initialVelocitySymbolicParameters = initialVelocity

        var initialParameterValues: Dictionary<Parameter, Double> = [:]
        initialPosition.forEach({ initialParameterValues[$0] = 0.0 })
        initialVelocity.forEach({ initialParameterValues[$0] = 0.0 })

        var ineqConstraints: [Node] = []
        var eqConstraints: [Assign] = []
        //==== Misc Constraints ====
        // Initial conditions
        for i in 0..<6 {
            eqConstraints.append(x[i, 0] ≈ initialPosition[i])
            eqConstraints.append(v[i, 0] ≈ initialVelocity[i])
        }

        // Maximum force
        for t in 0..<self.numTimeHorizonSteps {
            ineqConstraints.append(u[0, t] <= self.maximumForce)
            ineqConstraints.append(u[0, t] >= -1*self.maximumForce)
        }

        //==== Dynamics Constraints ====
        // Position and Velcoity
        for t in 1..<self.numTimeHorizonSteps {
            // Mass 1
            eqConstraints.append( x[0,t] ≈ x[0,t-1] + v[0,t-1]*self.mpc_dt )
            eqConstraints.append( v[0,t] ≈ v[0,t-1] + a[0,t-1]*self.mpc_dt )
            eqConstraints.append( a[0,t] ≈ (0      - x[0,t]) + (x[1,t] - x[0,t]) + u[0,t] )

            // Mass 2
            eqConstraints.append( x[1,t] ≈ x[1,t-1] + v[1,t-1]*self.mpc_dt )
            eqConstraints.append( v[1,t] ≈ v[1,t-1] + a[1,t-1]*self.mpc_dt )
            eqConstraints.append( a[1,t] ≈ (x[0,t] - x[1,t]) + (x[2,t] - x[1,t]) - u[0,t] )

            // Mass 3
            eqConstraints.append( x[2,t] ≈ x[2,t-1] + v[2,t-1]*self.mpc_dt )
            eqConstraints.append( v[2,t] ≈ v[2,t-1] + a[2,t-1]*self.mpc_dt )
            eqConstraints.append( a[2,t] ≈ (x[1,t] - x[2,t]) + (x[3,t] - x[2,t]) + u[1,t] )

            // Mass 4
            eqConstraints.append( x[3,t] ≈ x[3,t-1] + v[3,t-1]*self.mpc_dt )
            eqConstraints.append( v[3,t] ≈ v[3,t-1] + a[3,t-1]*self.mpc_dt )
            eqConstraints.append( a[3,t] ≈ (x[2,t] - x[3,t]) + (x[4,t] - x[3,t]) + u[2,t] )

            // Mass 5
            eqConstraints.append( x[4,t] ≈ x[4,t-1] + v[4,t-1]*self.mpc_dt )
            eqConstraints.append( v[4,t] ≈ v[4,t-1] + a[4,t-1]*self.mpc_dt )
            eqConstraints.append( a[4,t] ≈ (x[3,t] - x[4,t]) + (x[5,t] - x[4,t]) - u[1,t] )

            // Mass 6
            eqConstraints.append( x[5,t] ≈ x[5,t-1] + v[5,t-1]*self.mpc_dt )
            eqConstraints.append( v[5,t] ≈ v[5,t-1] + a[5,t-1]*self.mpc_dt )
            eqConstraints.append( a[5,t] ≈ (x[4,t] - x[5,t]) + (0      - x[5,t]) - u[2,t] )
        }

        //==== Objective ====
        let objectiveNode: Node = sum(x.**2) + sum(v.**2) + sum(u.**2)

        guard let objective = SymbolicObjective(min: objectiveNode, subjectTo: SymbolicVector(ineqConstraints), equalityConstraints: eqConstraints, ordering: ordering, parameterValues: initialParameterValues) else {
            throw MPCError.misc("Unable to construct symbolic objective")
        }

        return objective
    }
}