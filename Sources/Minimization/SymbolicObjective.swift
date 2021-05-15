import LASwift
import Numerics
import SymbolicMath
import Collections
import Foundation

struct SymbolicObjective: Objective, VariableOrdered {

    let variables: Set<Variable>
    var numVariables: Int {
        return self.variables.count
    }
    var _ordering: OrderedSet<Variable>?

    var objectiveNode: Node
    var symbolicGradient: SymbolicVector = []
    var symbolicHessian: SymbolicMatrix = []

    var numConstraints: Int {
        if let constraints = self.symbolicConstraints {
            return constraints.count
        } else {
            return 0
        }
    }
    var symbolicConstraints: SymbolicVector?
    var symbolicConstraintsGradient: [SymbolicVector]?
    var symbolicConstraintsHessian: [SymbolicMatrix]?

    let equalityConstraintMatrix: Matrix? = nil
    let equalityConstraintVector: Vector? = nil

    public init?(min node: Node, subjectTo optionalConstraints: SymbolicVector? = nil, ordering optionalOrdering: OrderedSet<Variable>? = nil) {
        // Get the set of all variables
        if let constraints = optionalConstraints {
            self.variables = node.variables.union(constraints.variables)
        } else {
            self.variables = node.variables
        }

        // Save the objective node
        self.objectiveNode = node

        // Save the constraints if provided
        if let constraints = optionalConstraints {
            self.symbolicConstraints = constraints
        }

        // Set the ordering of the objective if provided
        // Needs to be done before the gradient and Hessian are constructed
        if let ordering = optionalOrdering {
            self.objectiveNode.setVariableOrder(ordering.union(self.orderedVariables))
        } else {
            self.objectiveNode.setVariableOrder(self.orderedVariables)
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

        if let _ = self.symbolicConstraints {
            // Set progenator constraints orders
            if let ordering = optionalOrdering {
                self.symbolicConstraints!.setVariableOrder(ordering.union(self.orderedVariables))
            } else {
                self.symbolicConstraints!.setVariableOrder(self.orderedVariables)
            }
        }

        // Construct derivatives of the constraints
        if let constraints = self.symbolicConstraints {

            self.symbolicConstraintsGradient = []
            self.symbolicConstraintsHessian = []

            // Construct gradients
            for symbol in constraints {
                guard let grad = symbol.gradient() else {
                    print("Unable to construct gradient of \(symbol)")
                    return nil
                }
                self.symbolicConstraintsGradient!.append(grad)
            }

            for symbol in constraints {
                guard let hess = symbol.hessian() else {
                    print("Unable to construct hessian of \(symbol)")
                    return nil
                }
                self.symbolicConstraintsHessian!.append(hess)
            }
        }

        // Note: this needs to be done after the objective and constraints are saved, otherwise
        // their ordering won't get set by SymbolicObjective.setVariableOrder
        if let ordering = optionalOrdering {
            self.setVariableOrder(ordering.union(self.orderedVariables))
        } else {
            self.setVariableOrder(self.orderedVariables)
        }
    }

    internal mutating func setVariableOrder<C>(_ newOrdering: C) where C: Collection, C.Element == Variable {
        self._ordering = OrderedSet<Variable>(newOrdering)

        // Propogate it to the children
        self.objectiveNode.setVariableOrder(newOrdering)
        if let _ = self.symbolicConstraints {
            self.symbolicConstraints!.setVariableOrder(newOrdering)
        }
        if let _ = self.symbolicConstraintsGradient {
            for i in 0..<self.numConstraints {
                self.symbolicConstraintsGradient![i].setVariableOrder(newOrdering)
            }
        }
        if let _ = self.symbolicConstraintsHessian {
            for i in 0..<self.numConstraints {
                self.symbolicConstraintsHessian![i].setVariableOrder(newOrdering)
            }
        }
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

    func inequalityConstraintsValue(_ x: Vector) -> [Double] {
        // Check that we actually have constraints
        guard let constraints = self.symbolicConstraints else {
            return [Double]()
        }

        do {
            return Array(try constraints.evaluate(x))
        } catch {
            print(error)
            Thread.callStackSymbols.forEach{print($0)}
            return Array(repeating: Double.nan, count: self.numConstraints)
        }
    }

    func inequalityConstraintsGradient(_ x: Vector) -> [Vector] {
        // Check that we actually have constraints
        guard let constraintsGradient = self.symbolicConstraintsGradient else {
            return [Vector]()
        }

        do {
            return try constraintsGradient.map({ try $0.evaluate(x) })
        } catch {
            print(error)
            Thread.callStackSymbols.forEach{print($0)}
            return constraintsGradient.map({ _ in Array(repeating: Double.nan, count: self.numConstraints) })
        }
    }

    func inequalityConstraintsHessian(_ x: Vector) -> [Matrix] {
        // Check that we actually have constraints
        guard let constraintsHessian = self.symbolicConstraintsHessian else {
            return [Matrix]()
        }

        do {
            return try constraintsHessian.map({ try $0.evaluate(x) })
        } catch {
            print("Unable to evaluate \(constraintsHessian) at \(x)")
            return constraintsHessian.map({ _ in Matrix(self.numVariables, self.numVariables, Double.nan) })
        }
    }
}