import LASwift
import Numerics

struct InequalitySolver {

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
    func residualNorm(
            objective: Objective,
            primal: Vector,
            dual: Vector,
            t: Double) -> Double {
        if(self.hasEqaulityConstraints) {
            // The norm of the full residual shown above
            let firstRow = Matrix(self.barrierGradient(objective: objective, at: primal, t: t)) + transpose(objective.equalityConstraintMatrix!)*Matrix(dual)
            let secondRow = objective.equalityConstraintMatrix!*Matrix(primal) - objective.equalityConstraintVector!
            return norm(append(firstRow, rows: secondRow).flat)
        } else {
            // If there are no equality constraints, then the residual is just the gradient,
            //  so we return the norm of it
            return norm(self.barrierGradient(objective: objective, at: primal, t: t))
        }
    }

    func infeasibleLinesearch(objective: Objective,
                            primalDirection: Vector,
                            dualDirection: Vector,
                            startPrimal: Vector,
                            startDual: Vector,
                            alpha: Double = 0.25,
                            beta: Double = 0.5,
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
        while(shiftedNorm > (1-alpha*s)*currentNorm || shiftedNorm.isNaN || shiftedValue.isNaN) {
            s = beta*s
            shiftedNorm = self.residualNorm(objective: objective,
                    primal: startPrimal + s.*primalDirection,
                    dual: startDual + s.*dualDirection,
                    t: t)
            shiftedValue = self.barrierValue(objective: objective, at: startPrimal + s.*primalDirection, t: t)
        }
        return s
    }

    func barrierValue(objective: Objective,  at x: Vector, t: Double) -> Double {
        return t * objective.value(x) + augmentValue(objective: objective, at: x)
    }

    func augmentValue(objective: Objective, at x: Vector) -> Double {
        return objective.inequalityConstraintsValue(x).reduce(0.0, {(currentSum, nextValue) in 
            return currentSum - Double.log(-1*nextValue)
        })
    }

    func barrierGradient(objective: Objective, at x: Vector, t: Double) -> Vector {
        return t .* objective.gradient(x) + augmentGradient(objective: objective, at: x)
    }

    func augmentGradient(objective: Objective, at x: Vector) -> Vector {
        let values = objective.inequalityConstraintsValue(x)
        let gradients = objective.inequalityConstraintsGradient(x)
        return zip(values, gradients).reduce(zeros(objective.numVariables), {(runningGradient, zippedValue) in
            let (fiValue, fiGradient) = zippedValue
            return runningGradient + -1/fiValue.*fiGradient
        })
    }

    func barrierHessian(objective: Objective, at x: Vector, t: Double) -> Matrix {
        return t .* objective.hessian(x) + augmentHessian(objective: objective, at: x)
    }

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

    mutating func infeasibleInequalityMinimize(
            objective: Objective,
            startPoint: Vector = [1.0],
            gradEpsilon: Double = 1.0e-3,
            maxIterations: Int = 100) throws -> (minimum: Double, point: Vector) {

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

        // Set start point
        var currentPoint = startPoint
        if(startPoint.count == 1 && startPoint[0] == 1.0) {
            currentPoint = ones(objective.numVariables)
        }
        var currentDual: Vector = []
        if(self.hasEqaulityConstraints) {
            currentDual = zeros(objective.equalityConstraintMatrix!.rows)
        }

        #if DEBUG 
            print("Starting point: \(currentPoint)")
        #endif

        // Hyper parameters
        var t = 1.0
        let mu = 20.0
        var tSteps = 0
        var totalSteps = 0
        let dualEpsilon = 1.0e-3

        var grad: Vector = self.barrierGradient(objective: objective, at: currentPoint, t: t)
        var H: Matrix = self.barrierHessian(objective: objective, at: currentPoint, t: t)
        var lambda = self.residualNorm(objective: objective, primal: currentPoint, dual: currentDual, t: t)

        while(Double(objective.numConstraints) / t > dualEpsilon && tSteps < 30) {

            var iterations: Int = 0

            // This needs to be recalulated because we changed  t
            lambda = self.residualNorm(objective: objective, primal: currentPoint, dual: currentDual, t: t)

            #if DEBUG
                let value = self.barrierValue(objective: objective, at: currentPoint, t: t)
                printDebug("\(tSteps):\(iterations)     Point:   \(currentPoint)")
                printDebug("\(tSteps):\(iterations)     Value:   \(value)")
                printDebug("\(tSteps):\(iterations)     Grad:    \(grad)")
                printDebug("\(tSteps):\(iterations)     Lambda:  \(lambda)")
            #endif

            while(lambda > gradEpsilon && iterations < maxIterations) {

                // These need to be initialized to make the compiler happy, but both will always
                // be set in the following if statement (they are also the wrong dimensions here)
                var stepDirectionPrimal: Vector = []
                var stepDirectionDual: Vector = []

                if(self.hasEqaulityConstraints) {
                    // These will always be non-nill as hasEqualityConstraints is true
                    let equalityConstraintMatrix = objective.equalityConstraintMatrix!
                    let equalityConstraintVector = objective.equalityConstraintVector!

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

                    stepDirectionPrimal = Array(stepDirectionWithDual[0..<objective.numVariables])
                    stepDirectionDual = Array(stepDirectionWithDual[objective.numVariables..<stepDirectionWithDual.count]) - currentDual
                    // We subtract off the current dual here because w = ν + Δν, while v = Δx
                } else {
                    // Construct the matrix:
                    // ┌     ┐
                    // │ ∇²f │
                    // └     ┘
                    // 
                    let newtonStepMatrix = H

                    // Construct the rightside vector
                    //  ┌    ┐
                    // -│ ∇f │
                    //  └    ┘
                    let newtonStepRightSide = -1.*Matrix(grad)

                    // ┌     ┐ ┌     ┐    ┌      ┐
                    // │ ∇²f │ │  v  │ = -│  ∇f  │
                    // └     ┘ └     ┘    └      ┘
                    // Where v is our primal step direction
                    stepDirectionPrimal = try LASwift.linsolve(newtonStepMatrix, newtonStepRightSide).flat
                }

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

                grad = self.barrierGradient(objective: objective, at: currentPoint, t: t)
                H = self.barrierHessian(objective: objective, at: currentPoint, t: t)
                lambda = self.residualNorm(objective: objective, primal: currentPoint, dual: currentDual, t: t)

                #if DEBUG
                    let value = self.barrierValue(objective: objective, at: currentPoint, t: t)
                    printDebug("\(tSteps):\(iterations)     Point:   \(currentPoint)")
                    printDebug("\(tSteps):\(iterations)     Value:   \(value)")
                    printDebug("\(tSteps):\(iterations)     Grad:    \(grad)")
                    printDebug("\(tSteps):\(iterations)     Lambda:  \(lambda)")
                #endif
            }
            t *= mu
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
}