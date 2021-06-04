//
// Created by Ian Ruh on 5/5/21.
//
import LASwift
import RealModule

func newtonStepDirection(startingPoint: Vector, gradient: Vector, hessian: Matrix) throws -> Vector {
    // Solve for the newton step Δx: ∇²f Δx = -1 * ∇f
    let step = try LASwift.linsolve(hessian, -1.*Matrix(gradient))
    return step.flat // linsolve always returns a matrix at the moment, so we just flatten it
}

func approxBackTrackingLineSearch(
        objective: Objective,
        startPoint: Vector,
        startValue: Double,
        startGradient: Vector,
        stepDirection: Vector,
        alpha: Double = 0.25,
        beta: Double = 0.5) -> Double {

    var t = 1.0

    while(objective.value(startPoint + t.*stepDirection) > startValue + alpha*t.*startGradient*stepDirection) {
        t = beta * t
    }

    return t
}

func unconstrainedMinimize(
        _ objective: Objective,
        startPoint: Vector = [1.0], // Placeholder, even if not set
        gradEpsilon: Double = 1.0e-6,
        maxIterations: Int = 100,
        debugInfo: Bool = false) throws -> Vector {

    // Set start point
    var currentPoint = startPoint
    if(startPoint.count == 1 && startPoint[0] == 1.0) {
        currentPoint = ones(objective.numVariables)
    }

    if(debugInfo) {
        print("Starting point: \(startPoint)")
    }

    var value = objective.value(currentPoint)
    var grad = objective.gradient(currentPoint)
    var H = objective.hessian(currentPoint)

    var iterations: Int = 0
    while(norm(grad) > gradEpsilon && iterations < maxIterations) {
        let stepDirection = try newtonStepDirection(startingPoint: currentPoint, gradient: grad, hessian: H)

        // Not really the step length as the newton step direction isn't normalized
        let stepLength = approxBackTrackingLineSearch(
                objective: objective,
                startPoint: currentPoint,
                startValue: value,
                startGradient: grad,
                stepDirection: stepDirection)
        currentPoint = currentPoint + stepLength.*stepDirection

        value = objective.value(currentPoint)
        grad = objective.gradient(currentPoint)
        H = objective.hessian(currentPoint)
        iterations += 1
    }

    if(debugInfo) {
        print("Numer of Iterations: \(iterations)")
        print("Gradient Norm: \(norm(grad))")
        print("Minimum Location: \(currentPoint)")
        print("Objective Value: \(value)")
    }

    return currentPoint
}

/// Eqaulity Constrained Minimization using Newton's method. [https://web.stanford.edu/class/ee364a/lectures/equality.pdf](This)
/// is probably the best resource too look at (or his book as well).
///
/// Also, not that even though out equality constraints are of the form Ax=b, we don't actually need b here. Because we
/// assume that the starting point is feasible (e.g. Ax=b for the starting point), and every newton step direction is
/// constrained to be in the null space of A, then every subsequent point has to satisfy Ax=b, even though we don't
/// know what b is.
///
/// - Parameters:
///   - objective:
///   - equalityConstraintMatrix:
///   - equalityConstraintVector:
///   - startPoint:
///   - gradEpsilon:
///   - maxIterations:
///   - debugInfo:
/// - Returns:
/// - Throws:
func equalityConstrainedMinimize(
        objective: Objective,
        equalityConstraintMatrix: Matrix,
        startPoint: Vector = [1.0, 1.0],
        gradEpsilon: Double = 1.0e-6,
        maxIterations: Int = 100,
        debugInfo: Bool = false) throws -> Vector {

    // Check that the equality constraints and objective have the same number of variables
    guard objective.numVariables == equalityConstraintMatrix.cols else {
        throw MinimizationError.wrongNumberOfVariables("Number of variables in objective and equality constraint disagree")
    }

    // Set start point
    var currentPoint = startPoint
    if(startPoint.count == 1 && startPoint[0] == 1.0) {
        currentPoint = ones(objective.numVariables)
    }

    if(debugInfo) {
        print("Starting point: \(startPoint)")
    }

    var value = objective.value(currentPoint)
    var grad = objective.gradient(currentPoint)
    var H = objective.hessian(currentPoint)

    var iterations: Int = 0
    var lambda = norm(grad) // Newton deciment (this furst one is meaningless)
    while(lambda > gradEpsilon && iterations < maxIterations) {

        // Construct the matrix:
        // ┌         ┐
        // │ ∇f²  Aᵀ │
        // │  A   0  │
        // └         ┘
        // Where A is the matrix for our equality constraints
        let firstRow = LASwift.append(H, cols: transpose(equalityConstraintMatrix))
        let secondRow = LASwift.append(equalityConstraintMatrix, cols: zeros(equalityConstraintMatrix.rows, equalityConstraintMatrix.rows))
        let newtonStepMatrix = LASwift.append(firstRow, rows: secondRow)

        // Construct the rightside vector
        // ┌     ┐
        // │ -∇f │
        // │  0  │
        // └     ┘
        let newtonStepRightSide = LASwift.append(-1.*Matrix(grad), rows: zeros(equalityConstraintMatrix.rows, 1))

        let stepDirectionWithDual = try LASwift.linsolve(newtonStepMatrix, newtonStepRightSide).flat

        // We need to pull out the step direction from the vector as it includes the dual as well
        // ┌         ┐ ┌     ┐   ┌     ┐
        // │ ∇f²  Aᵀ │ │  v  │   │ -∇f │
        // │  A   0  │ │  w  │ = │  0  │
        // └         ┘ └     ┘   └     ┘
        // Where v is our primal step direction, and w would be the dual

        let stepDirection = Array(stepDirectionWithDual[0..<objective.numVariables])

        // Not really the step length as the newton step direction isn't normalized
        let stepLength = approxBackTrackingLineSearch(
                objective: objective,
                startPoint: currentPoint,
                startValue: value,
                startGradient: grad,
                stepDirection: stepDirection)
        currentPoint = currentPoint + stepLength.*stepDirection

        value = objective.value(currentPoint)
        grad = objective.gradient(currentPoint)
        H = objective.hessian(currentPoint)

        lambda = abs(grad*stepDirection / 2)

        iterations += 1
    }

    if(debugInfo) {
        print("Numer of Iterations: \(iterations)")
        print("Newton Decrement: \(lambda)")
        print("Minimum Location: \(currentPoint)")
        print("Objective Value: \(value)")
    }

    return currentPoint
}

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
        equalityConstraintMatrix: Matrix,
        equalityConstraintVector: Vector,
        primal: Vector,
        dual: Vector) -> Double {
    let firstRow = Matrix(objective.gradient(primal)) + transpose(equalityConstraintMatrix)*Matrix(dual)
    let secondRow = equalityConstraintMatrix*Matrix(primal) - equalityConstraintVector
    return norm(append(firstRow, rows: secondRow).flat)
}

func infeasibleLinesearch(objective: Objective,
                          equalityConstraintMatrix: Matrix,
                          equalityConstraintVector: Vector,
                          primalDirection: Vector,
                          dualDirection: Vector,
                          startPrimal: Vector,
                          startDual: Vector,
                          alpha: Double = 0.25,
                          beta: Double = 0.5) -> Double {

    var t = 1.0
    var shiftedNorm = residualNorm(objective: objective,
            equalityConstraintMatrix: equalityConstraintMatrix,
            equalityConstraintVector: equalityConstraintVector,
            primal: startPrimal + t.*primalDirection,
            dual: startDual + t.*dualDirection)
    let currentNorm = residualNorm(objective: objective,
            equalityConstraintMatrix: equalityConstraintMatrix,
            equalityConstraintVector: equalityConstraintVector,
            primal: startPrimal,
            dual: startDual)
    while(shiftedNorm > (1-alpha*t)*currentNorm) {
        t = beta*t
        shiftedNorm = residualNorm(objective: objective,
                equalityConstraintMatrix: equalityConstraintMatrix,
                equalityConstraintVector: equalityConstraintVector,
                primal: startPrimal + t.*primalDirection,
                dual: startDual + t.*dualDirection)
    }
    return t
}

func infeasibleEqualityMinimize(
        objective: Objective,
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

    var value = objective.value(currentPoint)
    var grad = objective.gradient(currentPoint)
    var H = objective.hessian(currentPoint)

    var iterations: Int = 0
    var lambda = norm(grad) // Newton decrement (this first one is meaningless)
    while(lambda > gradEpsilon && iterations < maxIterations) {

        // Construct the matrix:
        // ┌         ┐
        // │ ∇f²  Aᵀ │
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
        // │ ∇f²  Aᵀ │ │  v  │    │  ∇f  │
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
                startDual: currentDual)
        currentPoint = currentPoint + stepLength.*stepDirectionPrimal
        currentDual = currentDual + stepLength.*stepDirectionDual

        value = objective.value(currentPoint)
        grad = objective.gradient(currentPoint)
        H = objective.hessian(currentPoint)

        lambda = residualNorm(objective: objective, equalityConstraintMatrix: equalityConstraintMatrix, equalityConstraintVector: equalityConstraintVector, primal: currentPoint, dual: currentDual)

        iterations += 1

//        print("Lambda: \(lambda),        Primal: \(currentPoint),         Dual: \(currentDual)")
    }

    if(debugInfo) {
        print("Numer of Iterations: \(iterations)")
        print("Residual Norm: \(lambda)")
        print("Minimum Location: \(currentPoint)")
        print("Objective Value: \(value)")
    }

    return currentPoint
}