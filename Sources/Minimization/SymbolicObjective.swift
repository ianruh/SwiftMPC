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

    let equalityConstraintMatrix: Matrix?
    let equalityConstraintVector: Vector?

    let startPrimal: Vector?
    let startDual: Vector?

    public init?(min node: Node, subjectTo optionalConstraints: SymbolicVector? = nil, equalityMatrix: Matrix? = nil, equalityVector: Vector? = nil, startPrimal: Vector? = nil, startDual: Vector? = nil, ordering optionalOrdering: OrderedSet<Variable>? = nil) {
        // Get the set of all variables
        if let constraints = optionalConstraints {
            if let ordering  = optionalOrdering {
                self.variables = Set(ordering.union(node.variables).union(constraints.variables))
            } else {
                self.variables = node.variables.union(constraints.variables)
            }
        } else {
            if let ordering  = optionalOrdering {
                self.variables = Set(ordering.union(node.variables))
            } else {
                self.variables = node.variables
            }
        }

        // Save the objective node
        self.objectiveNode = node

        // Save the constraints if provided
        if let constraints = optionalConstraints {
            self.symbolicConstraints = constraints
        }

        // Save equality constraints
        //  TODO: Check dimensions
        self.equalityConstraintMatrix = equalityMatrix
        self.equalityConstraintVector =  equalityVector

        // Save the start points
        self.startPrimal = startPrimal
        self.startDual = startDual

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

    /// We want to solve the system
    ///  min s over x,s
    ///      f_i(x) <= s
    ///      Ax = b
    ///
    /// If s is negative then we are strictly feasible, if positive then not feasible
    /// If 0, then it's tricky, but we'll call it infeasible to be safe
    func startPoint() throws -> (primal: Vector, dual: Vector) {
        // We only need to find a strictly feasible point if we actually have inequality constraints
        if let symbolicConstraints  = self.symbolicConstraints {
            //  First check if the provided start points are strictly feasible
            if let startPrimal = self.startPrimal {
                if(try symbolicConstraints.evaluate(startPrimal) .<= 0.0) {
                    // Check if the startDual was provided
                    if let startDual = self.startDual {
                        return (primal: startPrimal, dual: startDual)
                    } else {
                        // We need to know haw large the dual vector should be
                        if let equalityMatrix = self.equalityConstraintMatrix {
                            return (primal: startPrimal, dual: zeros(equalityMatrix.rows))
                        } else {
                            return  (primal: startPrimal, dual: zeros(0))
                        }
                    }
                }
                // Just fall through if it's not strictly feasible
            }

            // Set up the problem
            let s: Variable = Variable("$$s")
            var constraints: [Node] = symbolicConstraints.map({originalConstraint in 
                return originalConstraint <= s
            })
            constraints.append(-10.0 <= s) // To alleive the singularity of the hessian
            let ordering: OrderedSet<Variable> = OrderedSet<Variable>([s]).union(self.orderedVariables)

            // We can always find a strictly feasible point for this problem. We choose an arbitrary x
            // and set s to be the maximum value of the  constraints  plus a little bit to make sure
            // s is strictly feasible
            let xStart = zeros(self.numVariables)
            let startConstraintValues = try symbolicConstraints.evaluate(xStart)
            let sStart = startConstraintValues.max()! + 1.0 // 1.0 is arbitrary
            // In the ordering we gave, s is the first variable, so we put it at the beginning of the start vector
            var startVector = [sStart]
            startVector.append(contentsOf: xStart)

            // We also need to expand the equality matrix if it is there
            var expandedEqualityMatrix = self.equalityConstraintMatrix
            if let equalityMatrix = expandedEqualityMatrix {
                // We add a column of zeros to the beginning, as s is the first variable in the ordering
                expandedEqualityMatrix = append(zeros(equalityMatrix.rows, 1), cols: equalityMatrix)
            }
            // The equality vector doesn't need to change at all

            guard let newObjective = SymbolicObjective(min: s, subjectTo: SymbolicVector(constraints), equalityMatrix: expandedEqualityMatrix, equalityVector: self.equalityConstraintVector, startPrimal: startVector, ordering: ordering) else {
                throw MinimizationError.misc("Unable to find feasible point")
            }

            var solver = InequalitySolver()
            solver.hyperParameters.valueThreshold = 0.0
            let (min, pt) = try solver.infeasibleInequalityMinimize(objective: newObjective)

            // Min should be negative if we have a feasible point
            guard min < 0.0 else {
                throw MinimizationError.misc("Problem may be infeasible. Found minimum feasible point of \(pt)")
            }

            let startPrimal = Array(pt[1..<pt.count])
            
            // Return the point
            if let equalityMatrix = self.equalityConstraintMatrix {
                return (primal: startPrimal, dual: zeros(equalityMatrix.rows))
            } else {
                return  (primal: startPrimal, dual: zeros(0))
            }
        } else {
            // We can return any point here, so we just default to 0s os the  right length
            if let equalityMatrix = self.equalityConstraintMatrix {
                return (primal: zeros(self.numVariables), dual: zeros(equalityMatrix.rows))
            } else {
                return  (primal: zeros(self.numVariables), dual: zeros(0))
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