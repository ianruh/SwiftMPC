import LASwift
import Numerics

struct InequalitySolver {

    public var hyperParameters:  HyperParameters = HyperParameters()

    private var hasEqaulityConstraints: Bool = false
    private var hasInequalityConstraints: Bool = false

    /// The norm of
    /// ┌          ┐
    /// │ ∇f + Aᵀν │
    /// │  Ax - b  │
    /// └          ┘
    ///
    /// - Parameters:
    ///   - objective:
    ///   - equalityConstraintMatrix:
    ///   - equalityConstraintVector:
    ///   - primal:
    ///   - dual:
    /// - Returns:
    @inlinable
    func residualNorm(
            objective: Objective,
            primal: Vector,
            dual: Vector,
            t: Double) -> Double {
        if(self.hasEqaulityConstraints) {
            // The norm of the full residual shown above
            let firstRow = Matrix(self.barrierGradient(objective: objective, at: primal, t: t)) + transpose(objective.equalityConstraintMatrix!)*Matrix(dual)
            let secondRow = objective.equalityConstraintMatrix!*Matrix(primal) - Matrix(objective.equalityConstraintVector!)
            return norm(append(firstRow, rows: secondRow).flat)
        } else {
            // If there are no equality constraints, then the residual is just the gradient,
            //  so we return the norm of it
            return norm(self.barrierGradient(objective: objective, at: primal, t: t))
        }
    }

    @inlinable
    func infeasibleLinesearch(objective: Objective,
                            primalDirection: Vector,
                            dualDirection: Vector,
                            startPrimal: Vector,
                            startDual: Vector,
                            t: Double) -> Double {
        var s = 1.0 // Starting line search length

        var shiftedNorm = self.residualNorm(objective: objective,
                primal: startPrimal + s.*primalDirection,
                dual: startDual + s.*dualDirection,
                t: t)
        let currentNorm = self.residualNorm(objective: objective,
                primal: startPrimal,
                dual: startDual,
                t: t)

        var shiftedValue = self.barrierValue(objective: objective, at: startPrimal + s.*primalDirection, t: t)

        // We need to make sure we aren't jumping over a barrier
        // e.g. if our barrier is -log(-(0.1 - x)), then the gradient is still defined
        // even when the objective isn't. So, we need to make sure our objective always
        // stays defined (e.g. is not NaN)
        while(shiftedNorm > (1-self.hyperParameters.lineSearchAlpha*s)*currentNorm || shiftedNorm.isNaN || shiftedValue.isNaN) {
            s = self.hyperParameters.lineSearchBeta*s
            shiftedNorm = self.residualNorm(objective: objective,
                    primal: startPrimal + s.*primalDirection,
                    dual: startDual + s.*dualDirection,
                    t: t)
            shiftedValue = self.barrierValue(objective: objective, at: startPrimal + s.*primalDirection, t: t)
        }
        return s
    }

    @inlinable
    func barrierValue(objective: Objective,  at x: Vector, t: Double) -> Double {
        return t * objective.value(x) + augmentValue(objective: objective, at: x)
    }

    @inlinable
    func augmentValue(objective: Objective, at x: Vector) -> Double {
        return objective.inequalityConstraintsValue(x).reduce(0.0, {(currentSum, nextValue) in 
            return currentSum - Double.log(-1*nextValue)
        })
    }

    @inlinable
    func barrierGradient(objective: Objective, at x: Vector, t: Double) -> Vector {
        return t .* objective.gradient(x) + augmentGradient(objective: objective, at: x)
    }

    @inlinable
    func augmentGradient(objective: Objective, at x: Vector) -> Vector {
        let values = objective.inequalityConstraintsValue(x)
        let gradients = objective.inequalityConstraintsGradient(x)
        return zip(values, gradients).reduce(zeros(objective.numVariables), {(runningGradient, zippedValue) in
            let (fiValue, fiGradient) = zippedValue
            return runningGradient + -1/fiValue.*fiGradient
        })
    }

    @inlinable
    func barrierHessian(objective: Objective, at x: Vector, t: Double) -> Matrix {
        return t .* objective.hessian(x) + augmentHessian(objective: objective, at: x)
    }

    @inlinable
    func augmentHessian(objective: Objective, at x: Vector) -> Matrix {
        let values = objective.inequalityConstraintsValue(x)
        let gradients = objective.inequalityConstraintsGradient(x)
        let hessians = objective.inequalityConstraintsHessian(x)
        return zip(values, zip(gradients, hessians)).reduce(zeros(objective.numVariables, objective.numVariables), {(runningHessian, zippedValue) in 
            let fiValue = zippedValue.0
            let fiGradient = zippedValue.1.0
            let fiHessian = zippedValue.1.1
            return runningHessian + (1/Double.pow(fiValue,2) .* Matrix(fiGradient)*transpose(Matrix(fiGradient))) + -1/fiValue.*fiHessian
        })
    }

    mutating func infeasibleInequalityMinimize(objective: Objective) throws -> (minimum: Double, point: Vector) {

        if let equalityConstraintMatrix =  objective.equalityConstraintMatrix {
            if let equalityConstraintVector = objective.equalityConstraintVector {
                self.hasEqaulityConstraints = true

                // Check that the equality constraints and objective have the same number of variables
                guard objective.numVariables == equalityConstraintMatrix.cols else {
                    throw MinimizationError.wrongNumberOfVariables("Number of variables in objective and equality constraint disagree")
                }
                // Check that the matrix and vector have the same height
                guard equalityConstraintMatrix.rows == equalityConstraintVector.count else {
                    throw MinimizationError.wrongNumberOfVariables("Equality constraint matrix has different number of rows than the equality constraint vector.")
                }
            }
        }

        // Record if we have inequality. Assuming correct dimensionality
        if(objective.numConstraints > 0) {
            self.hasInequalityConstraints = true
        }

        // Get start point
        var (currentPoint, currentDual): (Vector, Vector) = try objective.startPoint()
        // Check that they are the right dimensions
        guard currentPoint.count == objective.numVariables else {
            throw MinimizationError.wrongNumberOfVariables("Primal start \(currentPoint) does not have the same number of variables as the objective (\(objective.numVariables))")
        }
        if(self.hasEqaulityConstraints) {
            guard currentDual.count == objective.equalityConstraintMatrix!.rows else {
                throw MinimizationError.wrongNumberOfVariables("Dual start \(currentDual) does not have the same number of variables as equality constraints in the objective (\(objective.equalityConstraintMatrix!.rows))")
            }
        } else {
            // Just set the dual to empty even if they provide one
            currentDual = []
        }

        #if DEBUG 
            print("Starting point: \(currentPoint)")
        #endif

        // Hyper parameters
        var t = self.hyperParameters.homotopyParameterStart
        var tSteps = 0
        var totalSteps = 0

        var value = self.barrierValue(objective: objective, at: currentPoint, t: t)
        var grad: Vector = self.barrierGradient(objective: objective, at: currentPoint, t: t)
        var H: Matrix = self.barrierHessian(objective: objective, at: currentPoint, t: t)
        var lambda = self.residualNorm(objective: objective, primal: currentPoint, dual: currentDual, t: t)

        while(Double(objective.numConstraints) / t > self.hyperParameters.dualGapEpsilon && tSteps < self.hyperParameters.homotopyStagesMaximum && !(value < self.hyperParameters.valueThreshold)) {

            var iterations: Int = 0

            // This needs to be recalulated because we changed  t
            lambda = self.residualNorm(objective: objective, primal: currentPoint, dual: currentDual, t: t)

            #if DEBUG
                printDebug("\(tSteps):\(iterations)     Point:   \(currentPoint)")
                printDebug("\(tSteps):\(iterations)     Value:   \(value)")
                printDebug("\(tSteps):\(iterations)     Grad:    \(grad)")
                printDebug("\(tSteps):\(iterations)     Lambda:  \(lambda)")
            #endif

            while(lambda > self.hyperParameters.residualEpsilon && iterations < self.hyperParameters.newtonStepsStageMaximum && !(value < self.hyperParameters.valueThreshold)) {

                let (stepDirectionPrimal, stepDirectionDual) = try objective.stepSolver(gradient: grad, hessian: H, primal: currentPoint, dual: currentDual)

                // TODO: the next point value and residual are calculated twice, once in the line search and
                // again when actually calculating it. This would be a good place for memoization

                // Not really the step length as the newton step direction isn't normalized
                let stepLength = infeasibleLinesearch(
                        objective: objective,
                        primalDirection: stepDirectionPrimal,
                        dualDirection: stepDirectionDual,
                        startPrimal: currentPoint,
                        startDual: currentDual,
                        t: t)
                
                currentPoint = currentPoint + stepLength.*stepDirectionPrimal
                currentDual = currentDual + stepLength.*stepDirectionDual

                iterations += 1
                totalSteps += 1

                value = self.barrierValue(objective: objective, at: currentPoint, t: t)
                grad = self.barrierGradient(objective: objective, at: currentPoint, t: t)
                H = self.barrierHessian(objective: objective, at: currentPoint, t: t)
                lambda = self.residualNorm(objective: objective, primal: currentPoint, dual: currentDual, t: t)

                #if DEBUG
                    printDebug("\(tSteps):\(iterations)     Point:   \(currentPoint)")
                    printDebug("\(tSteps):\(iterations)     Value:   \(value)")
                    printDebug("\(tSteps):\(iterations)     Grad:    \(grad)")
                    printDebug("\(tSteps):\(iterations)     Lambda:  \(lambda)")
                #endif
            }
            t *= self.hyperParameters.homotopyParameterMultiplier
            tSteps += 1
        }

        let minimum = objective.value(currentPoint)

        #if DEBUG 
            printDebug("t: \(t)")
            printDebug("Numer of Iterations: \(totalSteps)")
            printDebug("Residual Norm: \(lambda)")
            printDebug("Minimum Location: \(currentPoint)")
            printDebug("Objective Value: \(objective.value(currentPoint))")
        #endif

        return (minimum: minimum, point: currentPoint)
    }

    struct HyperParameters {
        // Iteration Maximums
        var newtonStepsStageMaximum: Int = 100
        var homotopyStagesMaximum: Int = 50
        
        // Epsilons
        var residualEpsilon: Double = 1.0e-3
        var dualGapEpsilon: Double = 1.0e-3

        // Homtopy Parameters
        var homotopyParameterStart: Double = 1.0
        var homotopyParameterMultiplier: Double = 20.0

        // Line Search
        var lineSearchAlpha: Double = 0.25
        var lineSearchBeta: Double = 0.5

        // Misc
        var valueThreshold: Double = -1*Double.infinity
    }

}