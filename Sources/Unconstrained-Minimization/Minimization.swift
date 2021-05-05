//
// Created by Ian Ruh on 5/5/21.
//
import LASwift
import Numerics

func newtonStepDirection(startingPoint: Vector, gradient: Vector, hessian: Matrix) throws -> Vector {
    let step = try LASwift.linsolve(hessian, -1.*Matrix(gradient))
    return step.flat
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

func equalityConstrainedMinimize(
        objective: Objective,
        equalityConstraintMatrix: Matrix,
        equalityConstraintVector: Matrix,
        startPoint: Vector = [1.0, 1.0],
        gradEpsilon: Double = 1.0e-6,
        maxIterations: Int = 100,
        debugInfo: Bool = false) throws -> Vector {



    return [0.0, 0.0]
}