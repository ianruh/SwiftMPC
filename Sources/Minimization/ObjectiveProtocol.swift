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

    func inequalityConstraintsValue(_ x: Vector) -> [Double]

    func inequalityConstraintsGradient(_ x: Vector) -> [Vector]

    func inequalityConstraintsHessian(_ x: Vector) -> [Matrix]

    //================= Step Solver ================

    // func stepSolver()
}

public extension Objective {

    func inequalityConstraintsValue(_ x: Vector) -> [Double] {
        preconditionFailure("The Objective.inequalityConstraintsValue() method was called without an implementation.  This likely means you need to Objective.numConstraints = 0.")
    }

    func inequalityConstraintsGradient(_ x: Vector) -> [Vector] {
        preconditionFailure("The Objective.inequalityConstraintsGradient() method was called without an implementation.  This likely means you need to Objective.numConstraints = 0.")
    }

    func inequalityConstraintsHessian(_ x: Vector) -> [Matrix] {
        preconditionFailure("The Objective.inequalityConstraintsHessian() method was called without an implementation.  This likely means you need to Objective.numConstraints = 0.")
    }

}