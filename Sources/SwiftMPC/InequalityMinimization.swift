// Created 2020 github @ianruh

import LASwift
import RealModule

public struct Solver {
    /// The hyper parameters used by the solver.
    public var hyperParameters = HyperParameters()

    @usableFromInline
    internal var hasEqaulityConstraints: Bool = false

    public init() { }

    /// The norm of
    ///
    /// ```
    /// ┌          ┐
    /// │ ∇f + Aᵀν │
    /// │  Ax - b  │
    /// └          ┘
    /// ```
    ///
    /// - Parameters:
    ///   - objective: The objective veing minimized.
    ///   - primal: The current primal value.
    ///   - dual: The current dual value
    ///   - t: The current barrier parameter.
    /// - Returns: The residual  of the norm.
    @inlinable
    internal func residualNorm(
        objective: Objective,
        primal: Vector,
        dual: Vector,
        t: Double
    ) -> Double {
        if self.hasEqaulityConstraints {
            // The norm of the full residual shown above
            let firstRow = Matrix(self.barrierGradient(objective: objective, at: primal, t: t)) +
                transpose(objective.equalityConstraintMatrix!) * Matrix(dual)
            let secondRow = objective
                .equalityConstraintMatrix! * Matrix(primal) -
                Matrix(objective.equalityConstraintVector!)
            return norm(append(firstRow, rows: secondRow).flat)
        } else {
            // If there are no equality constraints, then the residual is just the gradient,
            //  so we return the norm of it
            return norm(self.barrierGradient(objective: objective, at: primal, t: t))
        }
    }

    /// Perform an infeasible start line search on the problem.
    ///
    /// If an exception is thrown saying that the maximum number of line search iterations has been reached,
    /// That usually means the current  primal/dual is infeasible, so it can't progress in any direction.
    ///
    /// - Parameters:
    ///   - objective: The objective being minimized.
    ///   - primalDirection: The primal direction to search in.
    ///   - dualDirection: The dual direction to seach in.
    ///   - startPrimal: The starting primal values.
    ///   - startDual: The starting dual value.
    ///   - t: The current barrier parameter.
    /// - Throws: If the maximum number of line search iterations has been hit.
    /// - Returns: The step length found.
    @inlinable
    internal func infeasibleLinesearch(objective: Objective,
                                       primalDirection: Vector,
                                       dualDirection: Vector,
                                       startPrimal: Vector,
                                       startDual: Vector,
                                       t: Double) throws -> Double
    {
        var s = 1.0 // Starting line search length

        var shiftedNorm = self.residualNorm(objective: objective,
                                            primal: startPrimal + s .* primalDirection,
                                            dual: startDual + s .* dualDirection,
                                            t: t)
        let currentNorm = self.residualNorm(objective: objective,
                                            primal: startPrimal,
                                            dual: startDual,
                                            t: t)

        var shiftedValue = self.barrierValue(
            objective: objective,
            at: startPrimal + s .* primalDirection,
            t: t
        )

        // We need to make sure we aren't jumping over a barrier
        // e.g. if our barrier is -log(-(0.1 - x)), then the gradient is still defined
        // even when the objective isn't. So, we need to make sure our objective always
        // stays defined (e.g. is not NaN)
        var numIterations: Int = 0
        while shiftedNorm > (1 - self.hyperParameters.lineSearchAlpha * s) * currentNorm ||
            shiftedNorm
            .isNaN || shiftedValue.isNaN
        {
            s = self.hyperParameters.lineSearchBeta * s
            shiftedNorm = self.residualNorm(objective: objective,
                                            primal: startPrimal + s .* primalDirection,
                                            dual: startDual + s .* dualDirection,
                                            t: t)
            shiftedValue = self.barrierValue(
                objective: objective,
                at: startPrimal + s .* primalDirection,
                t: t
            )
            numIterations += 1
            if numIterations > self.hyperParameters.lineSearchMaximumIterations {
                throw SwiftMPCError.misc("Reached maximum number of line search iterations")
            }
        }
        return s
    }

    /// The value of the barrier augmented objective.
    /// - Parameters:
    ///   - objective: The objective  being minimized.
    ///   - x: The current primal values.
    ///   - t: The current barrier  parameter.
    /// - Returns: The augmented  objective value.
    @inlinable
    internal func barrierValue(objective: Objective, at x: Vector, t: Double) -> Double {
        return t * objective.value(x) + objective.inequalityConstraintsValue(x)
    }

    /// The value of the barrier augmented objective's gradient.
    /// - Parameters:
    ///   - objective: The objective being minimized.
    ///   - x: The current primal value.
    ///   - t: The current barrier parameter.
    /// - Returns: The augmented objective's gradient.
    @inlinable
    internal func barrierGradient(objective: Objective, at x: Vector, t: Double) -> Vector {
        return t .* objective.gradient(x) + objective.inequalityConstraintsGradient(x)
    }

    /// The value  of the augmented objective's hessian.
    /// - Parameters:
    ///   - objective: The objective being minimized.
    ///   - x: The cureent primal value.
    ///   - t: The current barrier parameter.
    /// - Returns: The augmented  objective's hessian.
    @inlinable
    internal func barrierHessian(objective: Objective, at x: Vector, t: Double) -> Matrix {
        return t .* objective.hessian(x) + objective.inequalityConstraintsHessian(x)
    }

    /// Minimize an infeasible start, inequality constrained objective.
    /// - Parameter objective: The objective to minimize.
    /// - Throws: For many reasons, including (ill formed problems, evaluation problems, line search problems, and others).
    /// - Returns: The minimum objective value, the minimum's primal, and the minimum's dual).
    public mutating func infeasibleInequalityMinimize(objective: Objective) throws
        -> (minimum: Double, primal: Vector, dual: Vector)
    {
        if let equalityConstraintMatrix = objective.equalityConstraintMatrix {
            if let equalityConstraintVector = objective.equalityConstraintVector {
                self.hasEqaulityConstraints = true

                // Check that the equality constraints and objective have the same number of variables
                guard objective.numVariables == equalityConstraintMatrix.cols else {
                    throw SwiftMPCError
                        .wrongNumberOfVariables(
                            "Number of variables in objective and equality constraint disagree"
                        )
                }
                // Check that the matrix and vector have the same height
                guard equalityConstraintMatrix.rows == equalityConstraintVector.count else {
                    throw SwiftMPCError
                        .wrongNumberOfVariables(
                            "Equality constraint matrix has different number of rows than the equality constraint vector."
                        )
                }
            }
        }

        // Get start point
        var (currentPoint, currentDual): (Vector, Vector) = try objective.startPoint()
        // Check that they are the right dimensions
        guard currentPoint.count == objective.numVariables else {
            throw SwiftMPCError
                .wrongNumberOfVariables(
                    "Primal start \(currentPoint) does not have the same number of variables as the objective (\(objective.numVariables))"
                )
        }
        if self.hasEqaulityConstraints {
            guard currentDual.count == objective.equalityConstraintMatrix!.rows else {
                throw SwiftMPCError
                    .wrongNumberOfVariables(
                        "Dual start \(currentDual) does not have the same number of variables as equality constraints in the objective (\(objective.equalityConstraintMatrix!.rows))"
                    )
            }
        } else {
            // Just set the dual to empty even if they provide one
            currentDual = []
        }

        #if DEBUG
        printDebug("Starting Primal: \(currentPoint)")
        printDebug("Starting Dual: \(currentDual)")
        #endif

        // Hyper parameters
        var t = self.hyperParameters.homotopyParameterStart
        var tSteps = 0
        var totalSteps = 0

        var value = objective.value(currentPoint)
        var grad: Vector = self.barrierGradient(objective: objective, at: currentPoint, t: t)
        var H: Matrix = self.barrierHessian(objective: objective, at: currentPoint, t: t)
        var lambda = self.residualNorm(
            objective: objective,
            primal: currentPoint,
            dual: currentDual,
            t: t
        )

        var homotopyStagesExitCondition: Bool = (objective.numConstraints == 0) ||
            (Double(objective.numConstraints) / t > self.hyperParameters.dualGapEpsilon)
        HOMOTOPY_STAGES_LOOP: while homotopyStagesExitCondition, tSteps < self.hyperParameters
            .homotopyStagesMaximum, value > self.hyperParameters.valueThreshold
        {
            var iterations: Int = 0

            // This needs to be recalulated because we changed  t
            lambda = self.residualNorm(
                objective: objective,
                primal: currentPoint,
                dual: currentDual,
                t: t
            )

            #if DEBUG
            printDebug("\(tSteps):\(iterations)     Point:   \(currentPoint)")
            printDebug("\(tSteps):\(iterations)     Value:   \(value)")
            printDebug("\(tSteps):\(iterations)     Grad:    \(grad)")
            printDebug("\(tSteps):\(iterations)     Lambda:  \(lambda)")
            #endif

            while lambda > self.hyperParameters.residualEpsilon && iterations < self.hyperParameters
                .newtonStepsStageMaximum && value > self.hyperParameters.valueThreshold
            {
                let (stepDirectionPrimal, stepDirectionDual) = try objective.stepSolver(
                    gradient: grad,
                    hessian: H,
                    primal: currentPoint,
                    dual: currentDual
                )

                // TODO: the next point value and residual are calculated twice, once in the line search and
                // again when actually calculating it. This would be a good place for memoization

                // Not really the step length as the newton step direction isn't normalized
                let stepLength = try infeasibleLinesearch(
                    objective: objective,
                    primalDirection: stepDirectionPrimal,
                    dualDirection: stepDirectionDual,
                    startPrimal: currentPoint,
                    startDual: currentDual,
                    t: t
                )

                currentPoint = currentPoint + stepLength .* stepDirectionPrimal
                currentDual = currentDual + stepLength .* stepDirectionDual

                iterations += 1
                totalSteps += 1

                value = objective.value(currentPoint)
                grad = self.barrierGradient(objective: objective, at: currentPoint, t: t)
                H = self.barrierHessian(objective: objective, at: currentPoint, t: t)
                lambda = self.residualNorm(
                    objective: objective,
                    primal: currentPoint,
                    dual: currentDual,
                    t: t
                )

                #if DEBUG
                printDebug("\(tSteps):\(iterations)     Point:   \(currentPoint)")
                printDebug("\(tSteps):\(iterations)     Value:   \(value)")
                printDebug("\(tSteps):\(iterations)     Grad:    \(grad)")
                printDebug("\(tSteps):\(iterations)     Lambda:  \(lambda)")
                #endif
            }

            // If we have no inequality constraints, then our first homotopy stage is exact
            if objective.numConstraints == 0 {
                break HOMOTOPY_STAGES_LOOP
            }

            t *= self.hyperParameters.homotopyParameterMultiplier
            tSteps += 1
            homotopyStagesExitCondition = (objective.numConstraints == 0) ||
                (Double(objective.numConstraints) / t > self.hyperParameters.dualGapEpsilon)
        }

        let minimum = objective.value(currentPoint)

        #if DEBUG
        printDebug("t: \(t)")
        printDebug("Numer of Iterations: \(totalSteps)")
        printDebug("Residual Norm: \(lambda)")
        printDebug("Minimum Location: \(currentPoint)")
        printDebug("Objective Value: \(objective.value(currentPoint))")
        #endif

        return (minimum: minimum, primal: currentPoint, dual: currentDual)
    }

    /// This struct is just a container for the hyper parameters that can be used to customize the behavior of the solver.
    ///
    /// The default values of fairly aggressive, so will find pretty precisely the minimum. For real time applications, many of the
    /// iteration maximums can be heavily restricted.
    public struct HyperParameters {
        //==== Iteration Maximums ====

        /// The maximum number of newton steps per homotopy stage.
        public var newtonStepsStageMaximum: Int = 100

        /// The maximum number of homotopy stages to to perform.
        public var homotopyStagesMaximum: Int = 50

        //==== Epsilons ====

        /// The epsilon value used for the residual.
        public var residualEpsilon: Double = 1.0e-3

        /// The epsilon value used for the primal-dual gap.
        public var dualGapEpsilon: Double = 1.0e-3

        //==== Homtopy Parameters ====

        /// The starting value of the homotopy barrier parameter.
        public var homotopyParameterStart: Double = 1.0

        /// The multiplier for the homotopy barrier parameter. It is the factor that the parameter
        /// increases by after every stage.
        public var homotopyParameterMultiplier: Double = 20.0

        //==== Line Search ====
        /// Back tracking line search alpha parameter [reference](https://en.wikipedia.org/wiki/Backtracking_line_search
        public var lineSearchAlpha: Double = 0.25
        /// Back tracking line  search beta  parameter [reference](https://en.wikipedia.org/wiki/Backtracking_line_search)
        public var lineSearchBeta: Double = 0.5
        /// The maximum number  of line search iterations.
        public var lineSearchMaximumIterations: Int = 100

        //==== Misc ====
        /// A threshold for the value of the objective, If this value is achieved, then the solver returns.
        /// By default, the value is -inf, so has no effect on the solver.
        public var valueThreshold: Double = -1 * Double.infinity
    }
}
