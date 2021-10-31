// Created 2020 github @ianruh

import Collections
import LASwift
import SwiftMPC
import SymbolicMath
import XCTest

final class RegressionTests: XCTestCase {
    func testRegression1() {
        do {
            let x = Variable("x")
            let y = Variable("y")
            let z = Variable("z")

            let obj = x ** 4 + y ** 4 + z ** 4
            let constraints: SymbolicVector = [
                y >= 1.0,
                z >= 5.0,
            ]
            let equalityConstraints: [Assign] = [
                10.0 ≈ y,
                x ≈ 3.0,
            ]

            let expectedLocation: Vector = [3.0, 10.0, 5.0]

            guard let objective = SymbolicObjective(
                min: obj,
                subjectTo: constraints,
                equalityConstraints: equalityConstraints
            ) else {
                print("Unable to construct symbolic objective")
                XCTFail("Unable to construct symbolic objective for \(obj)")
                return
            }

            var solver = try Solver(objective: objective)
            let (primalStart, dualStart) = try objective.startPoint()
            let (_, pt, _) = try solver.infeasibleInequalityMinimize(primalStart: primalStart, dualStart: dualStart)

            XCTAssertTrue(
                pt.isApprox(expectedLocation, within: 0.1),
                "Calculate min location \(pt) is not equal to the expected one \(expectedLocation)"
            )
        } catch {
            print(error)
            XCTFail("Unnexpected excpetion thrown")
        }
    }

    func testRegression2() {
        do {
            let x = Variable("x")
            let y = Variable("y")
            let z = Variable("z")

            let obj = x ** 4 + y ** 4 + z ** 4
            let constraints: SymbolicVector = [
                y >= 1.0,
                z >= 5.0,
            ]
            let equalityConstraints: [Assign] = [
                10.0 ≈ y,
            ]

            let expectedLocation: Vector = [0.0, 10.0, 5.0]

            guard let objective = SymbolicObjective(
                min: obj,
                subjectTo: constraints,
                equalityConstraints: equalityConstraints
            ) else {
                print("Unable to construct symbolic objective")
                XCTFail("Unable to construct symbolic objective for \(obj)")
                return
            }
            
            var solver = try Solver(objective: objective)
            let (primalStart, dualStart) = try objective.startPoint()
            let (_, pt, _) = try solver.infeasibleInequalityMinimize(primalStart: primalStart, dualStart: dualStart)

            XCTAssertTrue(
                pt.isApprox(expectedLocation, within: 0.1),
                "Calculate min location \(pt) is not equal to the expected one \(expectedLocation)"
            )
        } catch {
            print(error)
            XCTFail("Unnexpected excpetion thrown")
        }
    }

    func testRegression3() {
        do {
            let x = Variable("x")
            let y = Variable("y")
            let z = Variable("z")

            let obj = x ** 4 + y ** 4 + z ** 4
            let constraints: SymbolicVector = [
                y >= 1.0,
                z >= 5.0,
            ]
            let equalityConstraints: [Assign] = []

            let expectedLocation: Vector = [0.0, 1.0, 5.0]

            guard let objective = SymbolicObjective(
                min: obj,
                subjectTo: constraints,
                equalityConstraints: equalityConstraints
            ) else {
                print("Unable to construct symbolic objective")
                XCTFail("Unable to construct symbolic objective for \(obj)")
                return
            }

            var solver = try Solver(objective: objective)
            let (primalStart, dualStart) = try objective.startPoint()
            let (_, pt, _) = try solver.infeasibleInequalityMinimize(primalStart: primalStart, dualStart: dualStart)

            XCTAssertTrue(
                pt.isApprox(expectedLocation, within: 0.1),
                "Calculate min location \(pt) is not equal to the expected one \(expectedLocation)"
            )
        } catch {
            print(error)
            XCTFail("Unnexpected excpetion thrown")
        }
    }

    func testRegression4() {
        do {
            let x = Variable("x")
            let y = Variable("y")
            let z = Variable("z")

            let obj = x ** 4 + y ** 4 + z ** 4
            let constraints: SymbolicVector = []
            let equalityConstraints: [Assign] = []

            let expectedLocation: Vector = [0.0, 0.0, 0.0]

            guard let objective = SymbolicObjective(
                min: obj,
                subjectTo: constraints,
                equalityConstraints: equalityConstraints
            ) else {
                print("Unable to construct symbolic objective")
                XCTFail("Unable to construct symbolic objective for \(obj)")
                return
            }

            var solver = try Solver(objective: objective)
            let (primalStart, dualStart) = try objective.startPoint()
            let (_, pt, _) = try solver.infeasibleInequalityMinimize(primalStart: primalStart, dualStart: dualStart)

            XCTAssertTrue(
                pt.isApprox(expectedLocation, within: 0.1),
                "Calculate min location \(pt) is not equal to the expected one \(expectedLocation)"
            )
        } catch {
            print(error)
            XCTFail("Unnexpected excpetion thrown")
        }
    }

    /// The hessian of this objective will be singular because x has no minimum. However, the bound of x
    /// will cause the augmented hessian to be non-singular (actually positive definite), so it should still work.
    func testRegression5() {
        do {
            let x = Variable("x")
            let y = Variable("y")

            let obj = x + y ** 4
            let constraints: SymbolicVector = [
                x >= 2.0,
            ]
            let equalityConstraints: [Assign] = []

            let expectedLocation: Vector = [2.0, 0.0]

            guard let objective = SymbolicObjective(
                min: obj,
                subjectTo: constraints,
                equalityConstraints: equalityConstraints
            ) else {
                print("Unable to construct symbolic objective")
                XCTFail("Unable to construct symbolic objective for \(obj)")
                return
            }

            var solver = try Solver(objective: objective)
            let (primalStart, dualStart) = try objective.startPoint()
            let (_, pt, _) = try solver.infeasibleInequalityMinimize(primalStart: primalStart, dualStart: dualStart)

            XCTAssertTrue(
                pt.isApprox(expectedLocation, within: 0.1),
                "Calculate min location \(pt) is not equal to the expected one \(expectedLocation)"
            )
        } catch {
            print(error)
            XCTFail("Unnexpected excpetion thrown")
        }
    }

    func testRegression6() {
        do {
            let numSteps: Int = 3
            let timeStep: Double = 0.1
            let maxAcceleration: Double = 1.0

            let x = Variable.vector("x", count: numSteps)
            let v = Variable.vector("v", count: numSteps)

            var ordering: OrderedSet<Variable> = []
            zip(x, v).forEach { pos, vel in
                ordering.append(pos)
                ordering.append(vel)
            }

            // Impose the max acceleration constraints
            var accelerationConstraints: [Node] = []
            for i in 0 ..< numSteps - 1 {
                accelerationConstraints
                    .append(v[i + 1] - v[i] <= (maxAcceleration * timeStep).symbol)
            }

            // Impose the dynamics constraints
            var dynamicsConstraints: [Assign] = []
            for i in 0 ..< numSteps - 1 {
                dynamicsConstraints.append(x[i + 1] - x[i] ≈ v[i] * timeStep.symbol)
            }

            // Impose initial conditions
            dynamicsConstraints.append(x[0] ≈ 0.0)
            dynamicsConstraints.append(v[0] ≈ 0.0)

            let obj = -1 * x.last! - v.last!
            let inequalityConstraints = SymbolicVector(accelerationConstraints)
            let equalityConstraints: [Assign] = dynamicsConstraints

            let expectedSolution: Vector = [0.0, 0.0, 0.0, 0.1, 0.01, 0.2]

            guard let objective = SymbolicObjective(
                min: obj,
                subjectTo: inequalityConstraints,
                equalityConstraints: equalityConstraints,
                ordering: ordering
            ) else {
                print("Unable to construct symbolic objective")
                XCTFail("Unable to construct symbolic objective for \(obj)")
                return
            }

            var solver = try Solver(objective: objective)
            let (primalStart, dualStart) = try objective.startPoint()
            let (_, pt, _) = try solver.infeasibleInequalityMinimize(primalStart: primalStart, dualStart: dualStart)

            XCTAssertTrue(
                pt.isApprox(expectedSolution, within: 0.1),
                "Calculate min solution \(pt) is not equal to the expected one \(expectedSolution)"
            )
        } catch {
            print(error)
            XCTFail("Unnexpected excpetion thrown")
        }
    }

    func testRegression7() {
        do {
            let x = Variable("x")
            let y = Variable("y")

            let obj = x ** 2 + y ** 2
            let constraints: SymbolicVector = [
                y >= 4.0,
            ]
            let equalityConstraints: [Assign] = [
                10.0 ≈ y,
            ]

            let expectedLocation: Vector = [0.0, 10.0]

            guard let objective = SymbolicObjective(
                min: obj,
                subjectTo: constraints,
                equalityConstraints: equalityConstraints
            ) else {
                print("Unable to construct symbolic objective")
                XCTFail("Unable to construct symbolic objective for \(obj)")
                return
            }

            var solver = try Solver(objective: objective)
            let (primalStart, dualStart) = try objective.startPoint()
            let (_, pt, _) = try solver.infeasibleInequalityMinimize(primalStart: primalStart, dualStart: dualStart)

            XCTAssertTrue(
                pt.isApprox(expectedLocation, within: 0.1),
                "Calculate min location \(pt) is not equal to the expected one \(expectedLocation)"
            )
        } catch {
            print(error)
            XCTFail("Unnexpected excpetion thrown")
        }
    }

    func testRegression8() {
        do {
            let x = Variable("x")
            let p = Parameter("p")

            let obj = x ** 2
            let constraints: SymbolicVector = [
                p <= x,
            ]

            let parameterValues: [Parameter: Double] = [p: 10.0]

            let expectedLocation: Vector = [10.0]

            guard let objective = SymbolicObjective(
                min: obj,
                subjectTo: constraints,
                parameterValues: parameterValues
            ) else {
                print("Unable to construct symbolic objective")
                XCTFail("Unable to construct symbolic objective for \(obj)")
                return
            }

            var solver = try Solver(objective: objective)
            let (primalStart, dualStart) = try objective.startPoint()
            let (_, pt, _) = try solver.infeasibleInequalityMinimize(primalStart: primalStart, dualStart: dualStart)

            XCTAssertTrue(
                pt.isApprox(expectedLocation, within: 0.1),
                "Calculate min location \(pt) is not equal to the expected one \(expectedLocation)"
            )
        } catch {
            print(error)
            XCTFail("Unnexpected excpetion thrown")
        }
    }

    func testRegression9() {
        do {
            let x = Variable("x")
            let y = Variable("y")
            let p = Parameter("p")

            let obj = x ** 2 + y ** 2
            let constraints: SymbolicVector = [
                p <= x,
            ]
            let equalityConstraints: [Assign] = [
                p ≈ y,
            ]

            let parameterValues: [Parameter: Double] = [p: 10.0]

            let expectedLocation: Vector = [10.0, 10.0]

            guard let objective = SymbolicObjective(
                min: obj,
                subjectTo: constraints,
                equalityConstraints: equalityConstraints,
                parameterValues: parameterValues
            ) else {
                print("Unable to construct symbolic objective")
                XCTFail("Unable to construct symbolic objective for \(obj)")
                return
            }

            var solver = try Solver(objective: objective)
            let (primalStart, dualStart) = try objective.startPoint()
            let (_, pt, _) = try solver.infeasibleInequalityMinimize(primalStart: primalStart, dualStart: dualStart)

            XCTAssertTrue(
                pt.isApprox(expectedLocation, within: 0.1),
                "Calculate min location \(pt) is not equal to the expected one \(expectedLocation)"
            )
        } catch {
            print(error)
            XCTFail("Unnexpected excpetion thrown")
        }
    }

    static var allTests = [
        ("SwiftMPC Regression 1", testRegression1),
        ("SwiftMPC Regression 2", testRegression2),
        ("SwiftMPC Regression 3", testRegression3),
        ("SwiftMPC Regression 4", testRegression4),
        ("SwiftMPC Regression 5", testRegression5),
        ("SwiftMPC Regression 6", testRegression6),
        ("SwiftMPC Regression 7", testRegression7),
        ("SwiftMPC Regression 8", testRegression8),
        ("SwiftMPC Regression 9", testRegression9),
    ]
}
