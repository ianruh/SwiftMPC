import XCTest
import Collections
import LASwift
import SymbolicMath
import Minimization

final class Unconstrained_MinimizationTests: XCTestCase {

    func testConstrainedMinimization1() {
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
            }

            var solver = InequalitySolver()
            let (min, pt) = try solver.infeasibleInequalityMinimize(objective: objective)

            XCTAssertTrue(pt.isApprox(expectedLocation, within: 0.1), "Calculate min location \(pt) is not equal to the expected one \(expectedLocation)")
        } catch {
            XCTFail("Unnexpected excpetion thrown")
        }
    }

    static var allTests = [
        ("Constrained Minimization 1", testConstrainedMinimization1),
    ]
}
