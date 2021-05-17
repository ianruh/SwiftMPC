import LASwift
import Numerics
import SymbolicMath
import Collections
import Foundation

public struct SymbolicObjective: Objective, VariableOrdered {

    public let variables: Set<Variable>
    public var numVariables: Int {
        return self.variables.count
    }
    public var _ordering: OrderedSet<Variable>?

    public var objectiveNode: Node
    public var symbolicGradient: SymbolicVector = []
    public var symbolicHessian: SymbolicMatrix = []

    public var numConstraints: Int {
        if let constraints = self.symbolicConstraints {
            return constraints.count
        } else {
            return 0
        }
    }

    public var symbolicConstraints: SymbolicVector?
    public var symbolicConstraintsGradient: [SymbolicVector]?
    public var symbolicConstraintsHessian: [SymbolicMatrix]?

    public var equalityConstraintMatrix: Matrix? = nil
    public var equalityConstraintVector: Vector? = nil

    let startPrimal: Vector?
    let startDual: Vector?

    // TODO: The equality constraints have some very strong assumptions
    // The equality constraint matrix and vector overule the symbolic equality constraints
    public init?(min node: Node, subjectTo optionalConstraints: SymbolicVector? = nil, equalityConstraints optionalEqualityConstraints: [Assign]? = nil, equalityConstraintMatrix optionalEqualityConstraintMatrix: Matrix? = nil, equalityConstraintVector optionalEqualityConstraintVector: Vector? = nil, startPrimal: Vector? = nil, startDual: Vector? = nil, ordering optionalOrdering: OrderedSet<Variable>? = nil) {
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
            // Handle an edge case where the symbolic constraints array is empty
            if(constraints.count > 0) {
                self.symbolicConstraints = constraints
            } else {
                self.symbolicConstraints = nil
            }
        }

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

        if let equalityConstraintMatrix = optionalEqualityConstraintMatrix {
            guard let equalityConstraintVector = optionalEqualityConstraintVector else {
                print("literal equality constraint matrix provided, but not literal equality constraint vector")
                return nil
            }
            // Make sure they are the same height
            guard equalityConstraintMatrix.rows == equalityConstraintVector.count else {
                print("Literal equality contraint matrix and literal equality constraint vector dimensions do not agree. \(equalityConstraintMatrix.rows) vs \(equalityConstraintVector.count)")
                return nil
            }
            // Make sure the matrix has  the right number of columns
            guard equalityConstraintMatrix.cols == self.orderedVariables.count else {
                print("Literal equality constraint matrix does not have the same number of columns as objective has variables. \(equalityConstraintMatrix.cols) vs \(self.orderedVariables.count)")
                return nil
            }

            self.equalityConstraintMatrix = equalityConstraintMatrix
            self.equalityConstraintVector = equalityConstraintVector
        } else {
            // Fall back to the symbolic equality constraints
            EQUALITY_CONSTRAINTS_IF: if let equalityConstraints = optionalEqualityConstraints {
                // Handle a bit of an edge case where the passed assign constraints are empty
                guard equalityConstraints.count > 0 else {
                    self.equalityConstraintMatrix = nil
                    self.equalityConstraintVector = nil
                    break EQUALITY_CONSTRAINTS_IF
                }

                // First, we'll simplify everything. Simpligying assign always results
                // in another assign node
                let simplifiedConstraints: [Assign] = equalityConstraints.map({ $0.simplify() as! Assign })
                var equalityMatrixRows: [Vector] = []
                var equalityVector: Vector = []
                for constraint in simplifiedConstraints {
                    // Extract the elements on each side
                    var leftElements: [Node] = []
                    var rightElements: [Node] = []
                    if let leftAddition = constraint.left as? Add {
                        leftElements = leftAddition.arguments
                    } else {
                        leftElements = [constraint.left]
                    }
                    if let rightAddition = constraint.right as? Add {
                        rightElements = rightAddition.arguments
                    } else {
                        rightElements = [constraint.right]
                    }

                    // Move everything to the left via subtraction
                    leftElements.append(contentsOf: rightElements.map({ Negative([$0]) }))
                    rightElements = [] // We moved everything left

                    // Check that the following holds true for every element
                    // - Contains one or no variables
                    var variablesDict: Dictionary<Variable, Double> = [:]
                    var constants: Double = 0.0
                    for el in leftElements {
                        // Check the number of variables
                        if(el.variables.count > 1) {
                            print("The constraint \(constraint) contains a non-linear term")
                            return nil
                        } else if(el.variables.count == 1) {
                            let variable = el.variables.first!
                            do {
                                let multiplier = try el.evaluate(withValues: [variable: 1.0])
                                if let currentMultiplier = variablesDict[variable] {
                                    variablesDict[variable] = currentMultiplier + multiplier
                                } else {
                                    variablesDict[variable] = multiplier
                                }
                            } catch {
                                print(error)
                                return nil
                            }
                        } else if(el.variables.count == 0) {
                            do {
                                let value = try el.evaluate(withValues: [:])
                                constants += value
                            } catch {
                                print(error)
                                return nil
                            }
                        }

                    }

                    // Append the row to the matrix and the value to the vector
                    equalityVector.append(-1*constants)
                    var row: Vector = []
                    for orderedVar in self.orderedVariables {
                        if let value = variablesDict[orderedVar] {
                            row.append(value)
                        } else {
                            row.append(0)
                        }
                    }
                    equalityMatrixRows.append(row)
                }

                self.equalityConstraintMatrix = Matrix(equalityMatrixRows)
                self.equalityConstraintVector = equalityVector
            } else {
                self.equalityConstraintMatrix = nil
                self.equalityConstraintVector = nil
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

    public mutating func setVariableOrder<C>(_ newOrdering: C) where C: Collection, C.Element == Variable {
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
    public func startPoint() throws -> (primal: Vector, dual: Vector) {
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
                            return (primal: startPrimal, dual: ones(equalityMatrix.rows))
                        } else {
                            return  (primal: startPrimal, dual: ones(0))
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
            var newConstraintsSymbolicVector = SymbolicVector(constraints)
            var originalConstraintsSymbolicVector = symbolicConstraints
            var ordering: OrderedSet<Variable> = OrderedSet<Variable>([s]).union(self.orderedVariables)

            // We can also end up with a singular hessian when our ambient problem involves a variable (lets say x),
            // but that variable is not involved in any inequality or equality constraints. This results in a row
            // and a column of all zeros. The conceptual understanding of this is that the problem is strictly feasible,
            // including equality constraints, for any value of x. Therefore, we can remove it from our feasibility
            // search and give it an arbitrary start value (zero).
            var unusedVariables: Set<Variable> = Set(self.orderedVariables).subtracting(symbolicConstraints.variables)
            
            if let equalityMatrix = self.equalityConstraintMatrix {
                var unusedEqualityVariables: Set<Variable> = []
                for i in 0..<equalityMatrix.cols {
                    if(equalityMatrix[col: i] .== 0.0) {
                        unusedEqualityVariables.update(with: self.orderedVariables[i])
                    }
                }
                unusedVariables = unusedVariables.intersection(unusedEqualityVariables)
            }

            // If we have unused variables, the we need to:
            // - Remove the variable from the ordering
            // - Remove that column from the equality matrix, if there is one
            // - Set the new ordering for the inequality constraints (both old copy and new)
            // - After solving, insert one into the resulting primal vector at the right locations
            // Note that we can no longer assume the number of variables is the same as the ambient problem + 1
            // Also, the equality constraint vector doesn't need to be changed as it doesn't depend on the number
            // of variables in the problem.

            // Remove the variables from the odering
            unusedVariables.forEach({ ordering.remove($0) })
            var shrunkAmbientOrdering = self.orderedVariables
            unusedVariables.forEach({ shrunkAmbientOrdering.remove($0) })

            // Set the inequality constraints ordering
            newConstraintsSymbolicVector.setVariableOrder(ordering)
            originalConstraintsSymbolicVector.setVariableOrder(shrunkAmbientOrdering)

            // Remove the columns from the equality matrix. Need to introduce intermediary though
            var shrunkEqualityMatrix: Matrix? = self.equalityConstraintMatrix
            if let equalityMatrix = self.equalityConstraintMatrix {
                let indexes: [Int] = unusedVariables.map({ self.orderedVariables.firstIndex(of: $0)! })
                let keptIndexes = Array(0..<self.orderedVariables.count).filter({ !indexes.contains($0) })
                shrunkEqualityMatrix = equalityMatrix[(er: Extractor.All, ec: Extractor.Pos(keptIndexes))]
            }

            // We can always find a strictly feasible point for this problem. We choose an arbitrary x
            // and set s to be the maximum value of the  constraints  plus a little bit to make sure
            // s is strictly feasible
            let xStart = ones(self.numVariables - unusedVariables.count) // Account for any variables that were rmeoved
            let startConstraintValues = try originalConstraintsSymbolicVector.evaluate(xStart)
            let sStart = startConstraintValues.max()! + 1.0 // 1.0 is arbitrary
            // In the ordering we gave, s is the first variable, so we put it at the beginning of the start vector
            var startVector = [sStart]
            startVector.append(contentsOf: xStart)

            // We also need to expand the equality matrix if it is there
            var expandedEqualityMatrix = shrunkEqualityMatrix
            if let equalityMatrix = expandedEqualityMatrix {
                // We add a column of zeros to the beginning, as s is the first variable in the ordering
                expandedEqualityMatrix = append(zeros(equalityMatrix.rows, 1), cols: equalityMatrix)
            }
            // The equality vector doesn't need to change at all

            guard let newObjective = SymbolicObjective(min: s, subjectTo: newConstraintsSymbolicVector, equalityConstraintMatrix: expandedEqualityMatrix, equalityConstraintVector: self.equalityConstraintVector, startPrimal: startVector, ordering: ordering) else {
                throw MinimizationError.misc("Unable to find feasible point")
            }

            var solver = InequalitySolver()
            solver.hyperParameters.valueThreshold = 0.0
            let (min, pt) = try solver.infeasibleInequalityMinimize(objective: newObjective)

            // Min should be negative if we have a feasible point
            guard min < 0.0 else {
                throw MinimizationError.misc("Problem may be infeasible. Found minimum feasible point of \(pt)")
            }

            var startPrimal: [Double] = Array(pt[1..<pt.count])

            // If we removed any unused variables, add them back in with initial value of one
            if(unusedVariables.count > 0) {
                var startPrimalDict: Dictionary<Variable, Double> = [:]
                for i in 1..<ordering.count {
                    startPrimalDict[ordering[i]] = pt[i]
                }
                startPrimal = []
                for variable in self.orderedVariables {
                    if let startValue = startPrimalDict[variable] {
                        startPrimal.append(startValue)
                    } else {
                        startPrimal.append(1.0)
                    }
                }
            }
            
            // Return the point
            if let equalityMatrix = self.equalityConstraintMatrix {
                return (primal: startPrimal, dual: ones(equalityMatrix.rows))
            } else {
                return  (primal: startPrimal, dual: ones(0))
            }
        } else {
            // We can return any point here, so we just default to 0s os the  right length
            var dual = ones(0)
            if let equalityMatrix = self.equalityConstraintMatrix {
                dual = ones(equalityMatrix.rows)
            }
            if let startPrimal = self.startPrimal {
                return (primal: startPrimal, dual: dual)
            } else {
                return (primal: ones(self.numVariables), dual: dual)
            }
        }
    }

    /// The value of the objective at a given point
    ///
    /// - Parameter x: The point to evaluate the objective at
    /// - Returns: The value of teh objective
    @inlinable
    public func value(_ x: Vector) -> Double {
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
    @inlinable
    public func gradient(_ x: Vector) -> Vector {
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
    @inlinable
    public func hessian(_ x: Vector) -> Matrix {
        do {
            return try self.symbolicHessian.evaluate(x)
        } catch {
            print(error)
            print("Returned NaN instead")
            return Matrix(self.numVariables, self.numVariables, Double.nan)
        }
    }

    @inlinable
    public func inequalityConstraintsValue(_ x: Vector) -> [Double] {
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

    @inlinable
    public func inequalityConstraintsGradient(_ x: Vector) -> [Vector] {
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

    @inlinable
    public func inequalityConstraintsHessian(_ x: Vector) -> [Matrix] {
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