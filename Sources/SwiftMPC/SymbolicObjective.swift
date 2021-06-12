// Created 2020 github @ianruh

import Collections
import Foundation
import LASwift
import RealModule
import SymbolicMath

public struct SymbolicObjective: Objective {
    public let variables: Set<Variable>
    public var numVariables: Int {
        return self.variables.count
    }

    public var orderedVariables: OrderedSet<Variable>

    public var objectiveNode: Node
    public var symbolicGradient: SymbolicVector = []
    public var symbolicHessian: SymbolicMatrix = []

    public var numConstraints: Int {
        if let constraints = self.symbolicConstraintsVector {
            return constraints.count
        } else {
            return 0
        }
    }

    public var symbolicConstraintsVector: SymbolicVector?
    public var symbolicConstraintsValue: Node?
    public var symbolicConstraintsGradient: SymbolicVector?
    public var symbolicConstraintsHessian: SymbolicMatrix?

    public var symbolicEqualityConstraintMatrix: SymbolicMatrix?
    public var symbolicEqualityConstraintVector: SymbolicVector?

    public var equalityConstraintMatrix: Matrix? {
        return try! self.symbolicEqualityConstraintMatrix?.evaluate(withValues: self.parameterValues)
    }

    public var equalityConstraintVector: Vector? {
        return try! self.symbolicEqualityConstraintVector?.evaluate(withValues: self.parameterValues)
    }

    let startPrimal: Vector?
    let startDual: Vector?

    @usableFromInline
    var parameterValues: [Parameter: Double] = [:]
    var parameters: Set<Parameter> = []

    // TODO: The equality constraints have some very strong assumptions
    // The equality constraint matrix and vector overule the symbolic equality constraints
    public init?(
        min node: Node,
        subjectTo optionalConstraints: SymbolicVector? = nil,
        equalityConstraints optionalEqualityConstraints: [Assign]? = nil,
        equalityConstraintMatrix optionalEqualityConstraintMatrix: SymbolicMatrix? = nil,
        equalityConstraintVector optionalEqualityConstraintVector: SymbolicVector? = nil,
        startPrimal: Vector? = nil,
        startDual: Vector? = nil,
        ordering optionalOrdering: OrderedSet<Variable>? = nil,
        parameterValues optionalParameterValues: [Parameter: Double] = [:]
    ) {
        // Get the set of all variables
        var allVariables = node.variables
        if let constraints = optionalConstraints {
            allVariables = allVariables.union(constraints.variables)
        }
        if let ordering = optionalOrdering {
            allVariables = allVariables.union(Set(ordering))
        }
        // The symbolic equality constraint matrices cannot have any variables, so we don't need to check them
        if let equalityConstraints = optionalEqualityConstraints {
            allVariables = allVariables.union(SymbolicVector(equalityConstraints).variables)
        }
        self.variables = allVariables

        // Get the set of all parameters
        var allParameters = node.parameters
        if let constraints = optionalConstraints {
            allParameters = allParameters.union(constraints.parameters)
        }
        // The symbolic equality constraint matrices can have parameters, so we need to check them
        if let matrix = optionalEqualityConstraintMatrix {
            // Check the provide matrix and vector
            allParameters = allParameters.union(matrix.parameters)
            if let vector = optionalEqualityConstraintVector {
                allParameters = allParameters.union(vector.parameters)
            }
        } else {
            if let equalityConstraints = optionalEqualityConstraints {
                allParameters = allParameters.union(SymbolicVector(equalityConstraints).parameters)
            }
        }
        self.parameters = allParameters

        // Save the parameter values
        self.parameterValues = optionalParameterValues

        // Save the objective node
        #if NO_SIMPLIFY
        self.objectiveNode = node
        #else
        self.objectiveNode = node.simplify()
        #endif

        // Save the constraints if provided
        if let constraints = optionalConstraints {
            // Handle an edge case where the symbolic constraints array is empty
            if constraints.count > 0 {
                #if NO_SIMPLIFY
                self.symbolicConstraintsVector = constraints
                #else
                self.symbolicConstraintsVector = constraints.simplify()
                #endif
            } else {
                self.symbolicConstraintsVector = nil
            }
        }

        // Save the start points
        self.startPrimal = startPrimal
        self.startDual = startDual

        // Set the ordering of the objective if provided
        // Needs to be done before the gradient and Hessian are constructed
        // We also need to initialize the ordering to the variables sorted
        self.orderedVariables = OrderedSet<Variable>(allVariables.sorted())
        do {
            if let ordering = optionalOrdering {
                // self.objectiveNode.setVariableOrder(ordering.union(self.orderedVariables))
                try self.setVariableOrder(ordering.union(self.orderedVariables))
            } else {
                // self.objectiveNode.setVariableOrder(self.orderedVariables)
                try self.setVariableOrder(self.orderedVariables)
            }
        } catch {
            printDebug(error)
            return nil
        }

        // The symbolic equality constraint matrix and vector are not allowed to have any variables
        if let matrix = optionalEqualityConstraintMatrix {
            guard matrix.variables.count == 0 else {
                printDebug("The equality constraint matrix cannot contain variables.")
                return nil
            }
        }
        if let vector = optionalEqualityConstraintVector {
            guard vector.variables.count == 0 else {
                printDebug("The equality constraint vector cannot contain variables.")
                return nil
            }
        }

        // Save the equality constraint matrices
        if let equalityConstraintMatrix = optionalEqualityConstraintMatrix {
            guard let equalityConstraintVector = optionalEqualityConstraintVector else {
                printDebug("literal equality constraint matrix provided, but not literal equality constraint vector")
                return nil
            }
            // Make sure they are the same height
            guard equalityConstraintMatrix.rows == equalityConstraintVector.count else {
                printDebug(
                    "Literal equality contraint matrix and literal equality constraint vector dimensions do not agree. \(equalityConstraintMatrix.rows) vs \(equalityConstraintVector.count)"
                )
                return nil
            }
            // Make sure the matrix has  the right number of columns
            guard equalityConstraintMatrix.cols == self.orderedVariables.count else {
                printDebug(
                    "Literal equality constraint matrix does not have the same number of columns as objective has variables. \(equalityConstraintMatrix.cols) vs \(self.orderedVariables.count)"
                )
                return nil
            }

            #if NO_SIMPLIFY
            self.symbolicEqualityConstraintMatrix = equalityConstraintMatrix
            self.symbolicEqualityConstraintVector = equalityConstraintVector
            #else
            self.symbolicEqualityConstraintMatrix = equalityConstraintMatrix.simplify()
            self.symbolicEqualityConstraintVector = equalityConstraintVector.simplify()
            #endif
        } else {
            // Fall back to the symbolic equality constraints
            EQUALITY_CONSTRAINTS_IF: if let equalityConstraints = optionalEqualityConstraints {
                // Handle a bit of an edge case where the passed assign constraints are empty
                guard equalityConstraints.count > 0 else {
                    self.symbolicEqualityConstraintMatrix = nil
                    self.symbolicEqualityConstraintVector = nil
                    break EQUALITY_CONSTRAINTS_IF
                }

                // First, we'll simplify everything. Simplifying assign always results
                // in another assign node. We always simplify this, even if the NO_SIMPLIFY
                // variable is set. Otherwise our shitty way detecting linear systems breaks because
                // the additions aren't flattened.
                let simplifiedConstraints: [Assign] = equalityConstraints.map { $0.simplify() as! Assign }
                var equalityMatrixRows: [SymbolicVector] = []
                var equalityVector: [Node] = []
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
                    leftElements.append(contentsOf: rightElements.map { Negative([$0]) })
                    rightElements = [] // We moved everything left

                    // Check that the following holds true for every element
                    // - Contains one or no variables
                    var variablesDict: [Variable: Node] = [:]
                    var constants: Node = Number(0)
                    for el in leftElements {
                        // Check the number of variables
                        if el.variables.count > 1 {
                            printDebug("The constraint \(constraint) contains a non-linear term")
                            return nil
                        } else if el.variables.count == 1 {
                            let variable = el.variables.first!
                            let multiplier: Node = el
                                .replace(variable,
                                         with: Number(1)) // Replace the variable by 1, so the result is the multiplier
                            if let currentMultiplier = variablesDict[variable] {
                                variablesDict[variable] = currentMultiplier + multiplier
                            } else {
                                variablesDict[variable] = multiplier
                            }
                        } else if el.variables.count == 0 {
                            constants = constants + el
                        }
                    }

                    // Append the row to the matrix and the value to the vector
                    equalityVector.append(Negative([constants]))
                    var row: [Node] = []
                    for orderedVar in self.orderedVariables {
                        if let value = variablesDict[orderedVar] {
                            row.append(value)
                        } else {
                            row.append(Number(0))
                        }
                    }
                    equalityMatrixRows.append(SymbolicVector(row))
                }

                #if NO_SIMPLIFY
                self.symbolicEqualityConstraintMatrix = SymbolicMatrix(equalityMatrixRows)
                self.symbolicEqualityConstraintVector = SymbolicVector(equalityVector)
                #else
                self.symbolicEqualityConstraintMatrix = SymbolicMatrix(equalityMatrixRows).simplify()
                self.symbolicEqualityConstraintVector = SymbolicVector(equalityVector).simplify()
                #endif
            } else {
                self.symbolicEqualityConstraintMatrix = nil
                self.symbolicEqualityConstraintVector = nil
            }
        }

        // Check that every parameter has a value
        for param in self.parameters {
            guard self.parameterValues[param] != nil else {
                printDebug("Parameter \(param) does not have a specified value")
                return nil
            }
        }

        #if DEBUG
        printDebug("Constructing Objective Derivatives")
        #endif

        // Try to construct the symbolic gradient
        guard let gradient = self.objectiveNode.gradient() else {
            return nil
        }
        #if NO_SIMPLIFY
        self.symbolicGradient = gradient
        #else
        self.symbolicGradient = gradient.simplify()
        #endif

        // Try to construct the Hessian
        guard let hessian = self.objectiveNode.hessian() else {
            return nil
        }
        #if NO_SIMPLIFY
        self.symbolicHessian = hessian
        #else
        self.symbolicHessian = hessian.simplify()
        #endif

        if let _ = self.symbolicConstraintsVector {
            do {
                // Set progenator constraints orders
                if let ordering = optionalOrdering {
                    try self.symbolicConstraintsVector!.setVariableOrder(ordering.union(self.orderedVariables))
                } else {
                    try self.symbolicConstraintsVector!.setVariableOrder(self.orderedVariables)
                }
            } catch {
                printDebug(error)
                return nil
            }
        }

        // Construct derivatives of the constraints
        if let constraints = self.symbolicConstraintsVector {
            #if DEBUG
            printDebug("Constructing Constraint Derivatives")
            #endif

            var symbolicConstraintValue: Node = Number(0)
            var gradients: [SymbolicVector] = []
            var hessians: [SymbolicMatrix] = []

            // Construct the value
            symbolicConstraintValue = Add(constraints.map { -1 * Ln(-1 * $0) })

            // Construct gradients
            for symbol in constraints {
                guard let grad = symbol.gradient() else {
                    printDebug("Unable to construct gradient of \(symbol)")
                    return nil
                }
                #if NO_SIMPLIFY
                gradients.append(grad)
                #else
                gradients.append(grad.simplify())
                #endif
            }

            // Construct hessian
            for symbol in constraints {
                guard let hess = symbol.hessian() else {
                    printDebug("Unable to construct hessian of \(symbol)")
                    return nil
                }
                #if NO_SIMPLIFY
                hessians.append(hess)
                #else
                hessians.append(hess.simplify())
                #endif
            }

            // Construct the final gradient
            let symbolicConstraintGradient: SymbolicVector = zip(constraints, gradients)
                .reduce(zeros(self.orderedVariables.count).symbolic) { currentSum, nextPair in
                    let const = nextPair.0
                    let grad = nextPair.1
                    return currentSum + (-1 / const) .* grad
                }

            // Construct the final hessian
            let symbolicConstraintHessian: SymbolicMatrix = zip(constraints, zip(gradients, hessians))
                .reduce(zeros(self.orderedVariables.count, self.orderedVariables.count)
                    .symbolic) { currentSum, nextTriple in
                    let const = nextTriple.0
                    let grad = nextTriple.1.0
                    let hess = nextTriple.1.1
                    return currentSum + (1 / const ** 2 .* (grad * grad)) + -1 / const .* hess
                }

            #if DEBUG
            printDebug("Simplifying Constraint Derivatives")
            #endif

            // Save the value, gradient, and hessian
            #if NO_SIMPLIFY
            self.symbolicConstraintsValue = symbolicConstraintValue
            self.symbolicConstraintsGradient = symbolicConstraintGradient
            self.symbolicConstraintsHessian = symbolicConstraintHessian
            #else
            self.symbolicConstraintsValue = symbolicConstraintValue.simplify()
            self.symbolicConstraintsGradient = symbolicConstraintGradient.simplify()
            self.symbolicConstraintsHessian = symbolicConstraintHessian.simplify()
            #endif
        }

        // Note: this needs to be done after the objective and constraints are saved, otherwise
        // their ordering won't get set by SymbolicObjective.setVariableOrder
        do {
            if let ordering = optionalOrdering {
                try self.setVariableOrder(ordering.union(self.orderedVariables))
            } else {
                try self.setVariableOrder(self.orderedVariables)
            }
        } catch {
            printDebug(error)
            return nil
        }
    }

    public mutating func setVariableOrder<C>(_ newOrdering: C) throws where C: Collection, C.Element == Variable {
        try self.variables.forEach { variable in
            guard newOrdering.contains(variable) else {
                throw SwiftMPCError.misc("New ordering \(newOrdering) does not contain variable \(variable)")
            }
        }
        self.orderedVariables = OrderedSet<Variable>(newOrdering)

        // Propogate it to the children
        try self.objectiveNode.setVariableOrder(newOrdering)
        try self.symbolicGradient.setVariableOrder(newOrdering)
        try self.symbolicHessian.setVariableOrder(newOrdering)
        if let _ = self.symbolicConstraintsVector {
            try self.symbolicConstraintsVector!.setVariableOrder(newOrdering)
        }
        if let _ = self.symbolicConstraintsValue {
            try self.symbolicConstraintsValue!.setVariableOrder(newOrdering)
        }
        if let _ = self.symbolicConstraintsGradient {
            try self.symbolicConstraintsGradient!.setVariableOrder(newOrdering)
        }
        if let _ = self.symbolicConstraintsHessian {
            try self.symbolicConstraintsHessian!.setVariableOrder(newOrdering)
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
        if let symbolicConstraints = self.symbolicConstraintsVector {
            //  First check if the provided start points are strictly feasible
            if let startPrimal = self.startPrimal {
                if try symbolicConstraints.evaluate(startPrimal, withParameters: self.parameterValues) .<= 0.0 {
                    // Check if the startDual was provided
                    if let startDual = self.startDual {
                        return (primal: startPrimal, dual: startDual)
                    } else {
                        // We need to know haw large the dual vector should be
                        if let equalityMatrix = self.symbolicEqualityConstraintMatrix {
                            return (primal: startPrimal, dual: ones(equalityMatrix.rows))
                        } else {
                            return (primal: startPrimal, dual: ones(0))
                        }
                    }
                }
                // Just fall through if it's not strictly feasible
            }

            // Set up the problem
            let s = Variable("$$s")
            var constraints: [Node] = symbolicConstraints.map { originalConstraint in
                originalConstraint <= s
            }
            constraints.append(s >= -10.0) // To alleive the singularity of the hessian
            let newConstraintsSymbolicVector = SymbolicVector(constraints)
            let originalConstraintsSymbolicVector = symbolicConstraints
            var ordering = OrderedSet<Variable>([s]).union(self.orderedVariables)

            // We can also end up with a singular hessian when our ambient problem involves a variable (lets say x),
            // but that variable is not involved in any inequality or equality constraints. This results in a row
            // and a column of all zeros. The conceptual understanding of this is that the problem is strictly feasible,
            // including equality constraints, for any value of x. Therefore, we can remove it from our feasibility
            // search and give it an arbitrary start value (zero).
            var unusedVariables: Set<Variable> = Set(self.orderedVariables).subtracting(symbolicConstraints.variables)

            if let equalityMatrix = self.equalityConstraintMatrix {
                var unusedEqualityVariables: Set<Variable> = []
                for i in 0 ..< equalityMatrix.cols {
                    if equalityMatrix[col: i] .== 0.0 {
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
            unusedVariables.forEach { ordering.remove($0) }
            var shrunkAmbientOrdering = self.orderedVariables
            unusedVariables.forEach { shrunkAmbientOrdering.remove($0) }

            // Set the inequality constraints ordering
            try! newConstraintsSymbolicVector.setVariableOrder(ordering)
            try! originalConstraintsSymbolicVector.setVariableOrder(shrunkAmbientOrdering)

            // Remove the columns from the equality matrix. Need to introduce intermediary though
            var shrunkEqualityMatrix: Matrix? = self.equalityConstraintMatrix
            if let equalityMatrix = self.equalityConstraintMatrix {
                let indexes: [Int] = unusedVariables.map { self.orderedVariables.firstIndex(of: $0)! }
                let keptIndexes = Array(0 ..< self.orderedVariables.count).filter { !indexes.contains($0) }
                shrunkEqualityMatrix = equalityMatrix[(er: Extractor.All, ec: Extractor.Pos(keptIndexes))]
            }

            // We can always find a strictly feasible point for this problem. We choose an arbitrary x
            // and set s to be the maximum value of the  constraints  plus a little bit to make sure
            // s is strictly feasible
            let xStart = ones(self.numVariables - unusedVariables.count) // Account for any variables that were rmeoved
            let startConstraintValues = try originalConstraintsSymbolicVector.evaluate(
                xStart,
                withParameters: self.parameterValues
            )
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

            guard let newObjective = SymbolicObjective(
                min: s,
                subjectTo: newConstraintsSymbolicVector,
                equalityConstraintMatrix: expandedEqualityMatrix?.symbolic,
                equalityConstraintVector: self.equalityConstraintVector?.symbolic,
                startPrimal: startVector,
                ordering: ordering,
                parameterValues: self.parameterValues
            ) else {
                throw SwiftMPCError.misc("Unable to find feasible point")
            }

            #if DEBUG
            printDebug("=========== Starting Feasible Point Search ===========")
            #endif

            var solver = InequalitySolver()
            solver.hyperParameters.valueThreshold = 0.0
            let (min, pt, _) = try solver.infeasibleInequalityMinimize(objective: newObjective)

            // Min should be negative if we have a feasible point
            guard min < 0.0 else {
                throw SwiftMPCError.misc("Problem may be infeasible. Found minimum feasible point of \(pt)")
            }

            var startPrimal: [Double] = Array(pt[1 ..< pt.count])

            // If we removed any unused variables, add them back in with initial value of one
            if unusedVariables.count > 0 {
                var startPrimalDict: [Variable: Double] = [:]
                for i in 1 ..< ordering.count {
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
            #if DEBUG
            printDebug("Found feasible point: \(startPrimal)")
            printDebug("=========== Finished Feasible Point Search ===========")
            #endif

            // Return the point
            if let equalityMatrix = self.symbolicEqualityConstraintMatrix {
                return (primal: startPrimal, dual: ones(equalityMatrix.rows))
            } else {
                return (primal: startPrimal, dual: ones(0))
            }
        } else {
            // We can return any point here, so we just default to 0s os the  right length
            var dual = ones(0)
            if let equalityMatrix = self.symbolicEqualityConstraintMatrix {
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
            return try self.objectiveNode.evaluate(x, withParameters: self.parameterValues)
        } catch {
            printDebug(error)
            printDebug("Returned NaN instead")
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
            return try self.symbolicGradient.evaluate(x, withParameters: self.parameterValues)
        } catch {
            printDebug(error)
            printDebug("Returned NaN instead")
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
            return try self.symbolicHessian.evaluate(x, withParameters: self.parameterValues)
        } catch {
            printDebug(error)
            printDebug("Returned NaN instead")
            return Matrix(self.numVariables, self.numVariables, Double.nan)
        }
    }

    @inlinable
    public func inequalityConstraintsValue(_ x: Vector) -> Double {
        // Check that we actually have constraints
        guard let constraint = self.symbolicConstraintsValue else {
            return 0.0
        }

        do {
            return try constraint.evaluate(x, withParameters: self.parameterValues)
        } catch {
            printDebug(error)
            Thread.callStackSymbols.forEach { print($0) }
            return Double.nan
        }
    }

    @inlinable
    public func inequalityConstraintsGradient(_ x: Vector) -> Vector {
        // Check that we actually have constraints
        guard let constraintsGradient = self.symbolicConstraintsGradient else {
            return zeros(self.numVariables)
        }

        do {
            return try constraintsGradient.evaluate(x, withParameters: self.parameterValues)
        } catch {
            printDebug(error)
            Thread.callStackSymbols.forEach { print($0) }
            return Array(repeating: Double.nan, count: self.numConstraints)
        }
    }

    @inlinable
    public func inequalityConstraintsHessian(_ x: Vector) -> Matrix {
        // Check that we actually have constraints
        guard let constraintsHessian = self.symbolicConstraintsHessian else {
            return zeros(self.numVariables, self.numVariables)
        }

        do {
            return try constraintsHessian.evaluate(x, withParameters: self.parameterValues)
        } catch {
            printDebug("Unable to evaluate \(constraintsHessian) at \(x)")
            return Matrix(self.numVariables, self.numVariables, Double.nan)
        }
    }
}
