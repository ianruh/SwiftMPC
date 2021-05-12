import LASwift
import Numerics
import SymbolicMath
import Foundation

struct SymbolicObjective: Objective {

    let numVariables: Int
    var objectiveNode: Node
    let symbolicGradient: SymbolicVector
    let symbolicHessian: SymbolicMatrix

    public init?(_ node: Node, ordering optionalOrdering: [Variable]? = nil) {
        self.numVariables = node.variables.count

        self.objectiveNode = node

        if let ordering = optionalOrdering {
            do {
                try self.objectiveNode.setVariableOrder(ordering)
            } catch {
                return nil
            }
        }

        // Try to construct the symbolic gradient
        guard let gradient = self.objectiveNode.gradient() else {
            return nil
        }
        self.symbolicGradient = gradient

        // Try to construct the Hessian
        guard let hessian = self.objectiveNode.hessian() else {
            return nil
        }
        self.symbolicHessian = hessian
    }

    /// The value of the objective at a given point
    ///
    /// - Parameter x: The point to evaluate the objective at
    /// - Returns: The value of teh objective
    func value(_ x: Vector) -> Double {
        do {
            return try self.objectiveNode.evaluate(x)
        } catch {
            print(error)
            print("Returned NaN instead")
            return Double.nan
        }
    }

    /// The value of the gradient at a given point
    ///
    /// - Parameter x: The point to evaluate the gradient at
    /// - Returns: The value of teh gradient
    func gradient(_ x: Vector) -> Vector {
        do {
            return try self.symbolicGradient.evaluate(x)
        } catch {
            print(error)
            print("Returned NaN instead")
            return Vector(repeating: Double.nan, count: self.numVariables)
        }
    }

    /// The value of the Hessian at a given point.
    ///
    /// - Parameter x: The point to evaluate the Hessian at.
    /// - Returns: The value of the Hessian.
    func hessian(_ x: Vector) -> Matrix {
        do {
            return try self.symbolicHessian.evaluate(x)
        } catch {
            print(error)
            print("Returned NaN instead")
            return Matrix(self.numVariables, self.numVariables, Double.nan)
        }
    }
}

//let min = try unconstrainedMinimize(QuinticObjective(n: 100), gradEpsilon: 1e-6, debugInfo: true)

//let equalityConstraints = Matrix([[1.0, 0]]) // x = 1, assuming starting point is 1,1
//let startPoint = [1.0, 1.0]
//let min = try equalityConstrainedMinimize(objective: QuinticObjective(n: 2), equalityConstraintMatrix: equalityConstraints, startPoint: startPoint, debugInfo: true)

//let equalityConstraints = Matrix([[1.0, 0]])
//let equalityConstraintVector = [2.0]
//let min = try infeasibleEqualityMinimize(
//        objective: QuinticObjective(n: 2),
//        equalityConstraintMatrix: equalityConstraints,
//        equalityConstraintVector: equalityConstraintVector,
//        debugInfo: true)

let x = Variable("x")
let y = Variable("y")
let z = Variable("z")
guard let objective = SymbolicObjective(x**4 + 3*y**4 + (z+4)**4) else {
    print("Unable to construct symbolic objective")
    exit(0)
}

let equalityConstraints = Matrix([[1.0, 0.0, 0.0]])
let equalityConstraintVector = [1.0]
let min = try infeasibleEqualityMinimize(
        objective: objective,
        equalityConstraintMatrix: equalityConstraints,
        equalityConstraintVector: equalityConstraintVector,
        debugInfo: true)

