import LASwift
import Numerics

struct InequalitySolver {
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
    func residualNorm(
            objective: ObjectiveWithInequality,
            equalityConstraintMatrix: Matrix,
            equalityConstraintVector: Vector,
            primal: Vector,
            dual: Vector,
            t: Double) -> Double {
        let firstRow = Matrix(t .* objective.gradient(primal) + augmentGradient(objective: objective, at: primal)) + transpose(equalityConstraintMatrix)*Matrix(dual)
        let secondRow = equalityConstraintMatrix*Matrix(primal) - equalityConstraintVector
        return norm(append(firstRow, rows: secondRow).flat)
    }

    func infeasibleLinesearch(objective: ObjectiveWithInequality,
                            equalityConstraintMatrix: Matrix,
                            equalityConstraintVector: Vector,
                            primalDirection: Vector,
                            dualDirection: Vector,
                            startPrimal: Vector,
                            startDual: Vector,
                            alpha: Double = 0.25,
                            beta: Double = 0.5,
                            t: Double) -> Double {

        var s = 1.0
        var shiftedNorm = self.residualNorm(objective: objective,
                equalityConstraintMatrix: equalityConstraintMatrix,
                equalityConstraintVector: equalityConstraintVector,
                primal: startPrimal + s.*primalDirection,
                dual: startDual + s.*dualDirection,
                t: t)
        let currentNorm = self.residualNorm(objective: objective,
                equalityConstraintMatrix: equalityConstraintMatrix,
                equalityConstraintVector: equalityConstraintVector,
                primal: startPrimal,
                dual: startDual,
                t: t)
        
        var shiftedValue = t * objective.value(startPrimal + s.*primalDirection) + augmentValue(objective: objective, at: startPrimal + s.*primalDirection)
        
        // We need to make sure we aren't jumping over a barrier
        // e.g. if our barrier is -log(-(0.1 - x)), then the gradient is still defined
        // even when the objective isn't. So, we need to make sure our objective always
        // stays defined (e.g. is not NaN)
        while(shiftedNorm > (1-alpha*s)*currentNorm || shiftedNorm.isNaN || shiftedValue.isNaN) {
            s = beta*s
            shiftedNorm = self.residualNorm(objective: objective,
                    equalityConstraintMatrix: equalityConstraintMatrix,
                    equalityConstraintVector: equalityConstraintVector,
                    primal: startPrimal + s.*primalDirection,
                    dual: startDual + s.*dualDirection,
                    t: t)
            shiftedValue = t * objective.value(startPrimal + s.*primalDirection) + augmentValue(objective: objective, at: startPrimal + s.*primalDirection)
        }
        return s
    }

    func augmentValue(objective: ObjectiveWithInequality, at x: Vector) -> Double {
        return -1*Double.log(objective.inequalityConstraintsValue(x).reduce(1.0, {(currentMul, nextValue) in 
            return currentMul * -1*nextValue
        }))
    }

    func augmentGradient(objective: ObjectiveWithInequality, at x: Vector) -> Vector {
        let values = objective.inequalityConstraintsValue(x)
        let gradients = objective.inequalityConstraintsGradient(x)
        return zip(values, gradients).reduce(zeros(objective.numVariables), {(runningGradient, zippedValue) in
            let (fiValue, fiGradient) = zippedValue
            return runningGradient + -1/fiValue.*fiGradient
        })
    }

    func augmentHessian(objective: ObjectiveWithInequality, at x: Vector) -> Matrix {
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

    func infeasibleInequalityMinimize(
            objective: ObjectiveWithInequality,
            equalityConstraintMatrix: Matrix,
            equalityConstraintVector: Vector,
            startPoint: Vector = [1.0],
            gradEpsilon: Double = 1.0e-6,
            maxIterations: Int = 100,
            debugInfo: Bool = false) throws -> Vector {

        // Check that the equality constraints and objective have the same number of variables
        guard objective.numVariables == equalityConstraintMatrix.cols else {
            throw MinimizationError.wrongNumberOfVariables("Number of variables in objective and equality constraint disagree")
        }
        guard equalityConstraintMatrix.rows == equalityConstraintVector.count else {
            throw MinimizationError.wrongNumberOfVariables("Equality constraint matrix has different number of rows than the equality constraint vector.")
        }

        // Set start point
        var currentPoint = startPoint
        if(startPoint.count == 1 && startPoint[0] == 1.0) {
            currentPoint = ones(objective.numVariables)
        }
        var currentDual = zeros(equalityConstraintVector.count)

        if(debugInfo) {
            print("Starting point: \(currentPoint)")
        }

        var t = 10.0
        let mu = 10.0
        var tSteps = 0
        var totalSteps = 0
        let dualEpsilon = 1.0e-5

        // var value: Double = t * objective.value(currentPoint) + augmentValue(objective: objective, at: currentPoint)
        var grad: Vector = t .* objective.gradient(currentPoint) + augmentGradient(objective: objective, at: currentPoint)
        var H: Matrix = t .* objective.hessian(currentPoint) + augmentHessian(objective: objective, at: currentPoint)

        var lambda = self.residualNorm(objective: objective, equalityConstraintMatrix: equalityConstraintMatrix, equalityConstraintVector: equalityConstraintVector, primal: currentPoint, dual: currentDual, t: t)
        while(Double(objective.numConstraints) / t > dualEpsilon && tSteps < 100) {

            var iterations: Int = 0

            // This needs to be recalulated because we changed  t
            lambda = self.residualNorm(objective: objective, equalityConstraintMatrix: equalityConstraintMatrix, equalityConstraintVector: equalityConstraintVector, primal: currentPoint, dual: currentDual, t: t)

            while(lambda > gradEpsilon && iterations < maxIterations) {

                // Construct the matrix:
                // ┌         ┐
                // │ ∇²f  Aᵀ │
                // │  A   0  │
                // └         ┘
                // Where A is the matrix for our equality constraints
                let firstRow = LASwift.append(H, cols: transpose(equalityConstraintMatrix))
                let secondRow = LASwift.append(equalityConstraintMatrix, cols: zeros(equalityConstraintMatrix.rows, equalityConstraintMatrix.rows))
                let newtonStepMatrix = LASwift.append(firstRow, rows: secondRow)

                // Construct the rightside vector
                //  ┌      ┐
                //  │  ∇f  │
                // -│ Ax-b │
                //  └      ┘
                let newtonStepRightSide = -1.*LASwift.append(Matrix(grad), rows: equalityConstraintMatrix*Matrix(currentPoint) - equalityConstraintVector)

                let stepDirectionWithDual = try LASwift.linsolve(newtonStepMatrix, newtonStepRightSide).flat

                // We need to pull out the step direction from the vector as it includes the dual as well
                // ┌         ┐ ┌     ┐    ┌      ┐
                // │ ∇²f  Aᵀ │ │  v  │    │  ∇f  │
                // │  A   0  │ │  w  │ = -│ Ax-b │
                // └         ┘ └     ┘    └      ┘
                // Where v is our primal step direction, and w would be the next dual (not the dual step)

                let stepDirectionPrimal = Array(stepDirectionWithDual[0..<objective.numVariables])
                let stepDirectionDual = Array(stepDirectionWithDual[objective.numVariables..<stepDirectionWithDual.count]) - currentDual
                // We subtract off the current dual here because w = ν + Δν, while v = Δx

                // Not really the step length as the newton step direction isn't normalized
                let stepLength = infeasibleLinesearch(
                        objective: objective,
                        equalityConstraintMatrix: equalityConstraintMatrix,
                        equalityConstraintVector: equalityConstraintVector,
                        primalDirection: stepDirectionPrimal,
                        dualDirection: stepDirectionDual,
                        startPrimal: currentPoint,
                        startDual: currentDual,
                        t: t)
                currentPoint = currentPoint + stepLength.*stepDirectionPrimal
                currentDual = currentDual + stepLength.*stepDirectionDual

                iterations += 1
                totalSteps += 1

                // value = t * objective.value(currentPoint) + augmentValue(objective: objective, at: currentPoint)
                grad = t .* objective.gradient(currentPoint) + augmentGradient(objective: objective, at: currentPoint)
                H = t .* objective.hessian(currentPoint) + augmentHessian(objective: objective, at: currentPoint)

                lambda = self.residualNorm(objective: objective, equalityConstraintMatrix: equalityConstraintMatrix, equalityConstraintVector: equalityConstraintVector, primal: currentPoint, dual: currentDual, t: t)
            }
            t *= mu
            tSteps += 1
        }

        if(debugInfo) {
            print("t: \(t)")
            print("Numer of Iterations: \(totalSteps)")
            print("Residual Norm: \(lambda)")
            print("Minimum Location: \(currentPoint)")
            print("Objective Value: \(objective.value(currentPoint))")
        }

        return currentPoint
    }
}