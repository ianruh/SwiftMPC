//
// Created by Ian Ruh on 5/5/21.
//
import LASwift

public protocol Objective {
    /// Number of variables taken by the objective
    var numVariables: Int { get }

    /// Number of inequality constraints
    var numConstraints: Int { get }

    //==================== Objective =================

    /// The value of the objective at a given point
    ///
    /// - Parameter x: The point to evaluate the objective at
    /// - Returns: The value of teh objective
    func value(_ x: Vector) -> Double

    /// The value of the gradient at a given point
    ///
    /// - Parameter x: The point to evaulate the gradient at
    /// - Returns: The value of teh gradient
    func gradient(_ x: Vector) -> Vector

    /// The value of the Hessian at a given point.
    ///
    /// - Parameter x: The point to evaluate the Hessian at.
    /// - Returns: The value of the Hessian.
    func hessian(_ x: Vector) -> Matrix

    //================= Equality ================

    var equalityConstraintMatrix: Matrix? { get }

    var equalityConstraintVector: Vector? { get }

    //=========== Inequality Constraints ============

    func inequalityConstraintsValue(_ x: Vector) -> Double

    func inequalityConstraintsGradient(_ x: Vector) -> Vector

    func inequalityConstraintsHessian(_ x: Vector) -> Matrix

    //=============== Start Point ================

    /// Strictly feasible start point
    /// dual should be zeros is you don't have one or care
    func startPoint() throws -> (primal: Vector, dual: Vector)

}

public extension Objective {

    //================= Place holders that should be overriden if there are constraints ================

    func inequalityConstraintsValue(_ x: Vector) -> Double {
        return 0.0
    }

    func inequalityConstraintsGradient(_ x: Vector) -> Vector {
        return zeros(self.numVariables)
    }

    func inequalityConstraintsHessian(_ x: Vector) -> Matrix {
        return zeros(self.numVariables, self.numVariables)
    }

    //================= Step Solver Default Implementation ================
    // TODO: This doesn't handle the case of singular H (it will explode in some random direction)
    // Here are some options: https://math.stackexchange.com/questions/2092999/a-question-about-newtons-method-for-equality-constrained-convex-minimization
    // It shouldn't come up if our objective is strongly convex, as then we are gaurenteed the hessian
    // will be non-singular. However, for the problem of finding a feasible point, we  minimize the scalar
    // function s, which is clearly not convex (it doesn't even have a minimum). We adapted the solver to
    // stop when s became negative, but it will explode before  then. In stead, we add a  onstraint to that
    // problem that s >= -10. This *shouldn't* restrict any feasible objectives, and will gaurentee that our
    // barrier augmented objective is non-singular.
    func stepSolver(gradient: Vector, hessian: Matrix, primal: Vector, dual: Vector) throws -> (primalStepDirection: Vector, dualStepDirection: Vector) {
        if(self.equalityConstraintMatrix != nil  && self.equalityConstraintVector != nil) {
            // These will always be non-nill as hasEqualityConstraints is true
            let equalityConstraintMatrix = self.equalityConstraintMatrix!
            let equalityConstraintVector = self.equalityConstraintVector!

            // Construct the matrix:
            // ┌         ┐
            // │ ∇²f  Aᵀ │
            // │  A   0  │
            // └         ┘
            // Where A is the matrix for our equality constraints
            let firstRow = LASwift.append(hessian, cols: transpose(equalityConstraintMatrix))
            let secondRow = LASwift.append(equalityConstraintMatrix, cols: zeros(equalityConstraintMatrix.rows, equalityConstraintMatrix.rows))
            let newtonStepMatrix = LASwift.append(firstRow, rows: secondRow)

            // Construct the rightside vector
            //  ┌      ┐
            //  │  ∇f  │
            // -│ Ax-b │
            //  └      ┘
            let newtonStepRightSide = -1.*LASwift.append(Matrix(gradient), rows: equalityConstraintMatrix*Matrix(primal) - Matrix(equalityConstraintVector))

            let stepDirectionWithDual = try LASwift.linsolve(newtonStepMatrix, newtonStepRightSide).flat

            // We need to pull out the step direction from the vector as it includes the dual as well
            // ┌         ┐ ┌     ┐    ┌      ┐
            // │ ∇²f  Aᵀ │ │  v  │    │  ∇f  │
            // │  A   0  │ │  w  │ = -│ Ax-b │
            // └         ┘ └     ┘    └      ┘
            // Where v is our primal step direction, and w would be the next dual (not the dual step)

            let primalStepDirection = Array(stepDirectionWithDual[0..<self.numVariables])
            let dualStepDirection = Array(stepDirectionWithDual[self.numVariables..<stepDirectionWithDual.count]) - dual
            // We subtract off the current dual here because w = ν + Δν, while v = Δx

            return (primalStepDirection: primalStepDirection, dualStepDirection: dualStepDirection)
        } else {
            // Construct the matrix:
            // ┌     ┐
            // │ ∇²f │
            // └     ┘
            // 
            let newtonStepMatrix = hessian

            // Construct the rightside vector
            //  ┌    ┐
            // -│ ∇f │
            //  └    ┘
            let newtonStepRightSide = -1.*Matrix(gradient)

            // ┌     ┐ ┌     ┐    ┌      ┐
            // │ ∇²f │ │  v  │ = -│  ∇f  │
            // └     ┘ └     ┘    └      ┘
            // Where v is our primal step direction
            let primalStepDirection = try LASwift.linsolve(newtonStepMatrix, newtonStepRightSide).flat

            return (primalStepDirection: primalStepDirection, dualStepDirection: [])
        }
    }
}