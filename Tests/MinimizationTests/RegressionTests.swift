import XCTest
import Collections
import LASwift
import SymbolicMath
import Minimization

final class RegressionTests: XCTestCase {

    func testRegression1() {
        do {
            let x = Variable("x")
            let y = Variable("y")
            let z = Variable("z")

            let obj = x**4 + y**4 + z**4
            let constraints: SymbolicVector = [
                1.0 <= y,
                5.0 <= z
            ]
            let equalityConstraints: [Assign] = [
                10.0 ≈ y,
                x ≈ 3.0
            ]

            let expectedLocation: Vector = [3.0, 10.0, 5.0]

            guard let objective = SymbolicObjective(min: obj, subjectTo: constraints, equalityConstraints: equalityConstraints) else {
                print("Unable to construct symbolic objective")
                XCTFail("Unable to construct symbolic objective for \(obj)")
                return
            }

            var solver = InequalitySolver()
            let (_, pt) = try solver.infeasibleInequalityMinimize(objective: objective)

            XCTAssertTrue(pt.isApprox(expectedLocation, within: 0.1), "Calculate min location \(pt) is not equal to the expected one \(expectedLocation)")
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

            let obj = x**4 + y**4 + z**4
            let constraints: SymbolicVector = [
                1.0 <= y,
                5.0 <= z
            ]
            let equalityConstraints: [Assign] = [
                10.0 ≈ y
            ]

            let expectedLocation: Vector = [0.0, 10.0, 5.0]

            guard let objective = SymbolicObjective(min: obj, subjectTo: constraints, equalityConstraints: equalityConstraints) else {
                print("Unable to construct symbolic objective")
                XCTFail("Unable to construct symbolic objective for \(obj)")
                return
            }

            var solver = InequalitySolver()
            let (_, pt) = try solver.infeasibleInequalityMinimize(objective: objective)

            XCTAssertTrue(pt.isApprox(expectedLocation, within: 0.1), "Calculate min location \(pt) is not equal to the expected one \(expectedLocation)")
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

            let obj = x**4 + y**4 + z**4
            let constraints: SymbolicVector = [
                1.0 <= y,
                5.0 <= z
            ]
            let equalityConstraints: [Assign] = []

            let expectedLocation: Vector = [0.0, 1.0, 5.0]

            guard let objective = SymbolicObjective(min: obj, subjectTo: constraints, equalityConstraints: equalityConstraints) else {
                print("Unable to construct symbolic objective")
                XCTFail("Unable to construct symbolic objective for \(obj)")
                return
            }

            var solver = InequalitySolver()
            let (_, pt) = try solver.infeasibleInequalityMinimize(objective: objective)

            XCTAssertTrue(pt.isApprox(expectedLocation, within: 0.1), "Calculate min location \(pt) is not equal to the expected one \(expectedLocation)")
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

            let obj = x**4 + y**4 + z**4
            let constraints: SymbolicVector = []
            let equalityConstraints: [Assign] = []

            let expectedLocation: Vector = [0.0, 0.0, 0.0]

            guard let objective = SymbolicObjective(min: obj, subjectTo: constraints, equalityConstraints: equalityConstraints) else {
                print("Unable to construct symbolic objective")
                XCTFail("Unable to construct symbolic objective for \(obj)")
                return
            }

            var solver = InequalitySolver()
            let (_, pt) = try solver.infeasibleInequalityMinimize(objective: objective)

            XCTAssertTrue(pt.isApprox(expectedLocation, within: 0.1), "Calculate min location \(pt) is not equal to the expected one \(expectedLocation)")
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

            let obj = x + y**4
            let constraints: SymbolicVector = [
                x >= 2.0
            ]
            let equalityConstraints: [Assign] = []

            let expectedLocation: Vector = [2.0, 0.0]

            guard let objective = SymbolicObjective(min: obj, subjectTo: constraints, equalityConstraints: equalityConstraints) else {
                print("Unable to construct symbolic objective")
                XCTFail("Unable to construct symbolic objective for \(obj)")
                return
            }

            var solver = InequalitySolver()
            let (_, pt) = try solver.infeasibleInequalityMinimize(objective: objective)

            XCTAssertTrue(pt.isApprox(expectedLocation, within: 0.1), "Calculate min location \(pt) is not equal to the expected one \(expectedLocation)")
        } catch {
            print(error)
            XCTFail("Unnexpected excpetion thrown")
        }
    }

    static var allTests = [
        ("Regression 1", testRegression1),
        ("Regression 2", testRegression2),
        ("Regression 3", testRegression3),
        ("Regression 4", testRegression4),
        ("Regression 5", testRegression5),
    ]
}
