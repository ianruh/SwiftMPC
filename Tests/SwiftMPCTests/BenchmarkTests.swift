// Created 2020 github @ianruh

import Collections
import LASwift
import SwiftMPC
import SymbolicMath
import XCTest

/// Tests to do:
final class BenchmarkTests: XCTestCase {
    /// Benchmark reference: http://benchmarkfcns.xyz/benchmarkfcns/boothfcn.html
    ///
    /// $$f(x,y)=(x+2y-7)^2+(2x+y-5)^2$$
    ///
    func testBooth() {
        do {
            let x = Variable("x")
            let y = Variable("y")

            let obj = (x + 2 * y - 7) ** 2 + (2 * x + y - 5) ** 2
            let constraints: SymbolicVector = []
            let equalityConstraints: [Assign] = []

            let expectedLocation: Vector = [1.0, 3.0]

            guard let objective = SymbolicObjective(
                min: obj,
                subjectTo: constraints,
                equalityConstraints: equalityConstraints
            ) else {
                print("Unable to construct symbolic objective")
                XCTFail("Unable to construct symbolic objective for \(obj)")
                return
            }

            var solver = Solver()
            solver.hyperParameters.residualEpsilon = 1e-8
            let (_, pt, _) = try solver.infeasibleInequalityMinimize(objective: objective)

            XCTAssertTrue(
                pt.isApprox(expectedLocation, within: 0.1),
                "Calculate min location \(pt) is not equal to the expected one \(expectedLocation)"
            )
        } catch {
            print(error)
            XCTFail("Unexpected error thrown")
        }
    }

    /// Benchmark reference: http://benchmarkfcns.xyz/benchmarkfcns/brentfcn.html
    ///
    /// $$f(x, y) = (x + 10)^2 + (y + 10)^2 + e^{-x^2 - y^2}$$
    ///
    func testBrent() {
        do {
            let x = Variable("x")
            let y = Variable("y")

            let obj = (x + 10) ** 2 + (y + 10) ** 2 + Exp(-1 * x ** 2 - y ** 2)
            let constraints: SymbolicVector = []
            let equalityConstraints: [Assign] = []

            let expectedLocation: Vector = [-10.0, -10.0]

            guard let objective = SymbolicObjective(
                min: obj,
                subjectTo: constraints,
                equalityConstraints: equalityConstraints
            ) else {
                print("Unable to construct symbolic objective")
                XCTFail("Unable to construct symbolic objective for \(obj)")
                return
            }

            var solver = Solver()
            solver.hyperParameters.residualEpsilon = 1e-8
            let (_, pt, _) = try solver.infeasibleInequalityMinimize(objective: objective)

            XCTAssertTrue(
                pt.isApprox(expectedLocation, within: 0.1),
                "Calculate min location \(pt) is not equal to the expected one \(expectedLocation)"
            )
        } catch {
            print(error)
            XCTFail("Unexpected error thrown")
        }
    }

    /// Benchmark reference: http://benchmarkfcns.xyz/benchmarkfcns/matyasfcn.html
    ///
    /// $$f(x, y)=0.26(x^2+y^2) -0.48xy$$
    ///
    func testMatyas() {
        do {
            let x = Variable("x")
            let y = Variable("y")

            let obj = 0.26 * (x ** 2 + y ** 2) - 0.48 * x * y
            let constraints: SymbolicVector = []
            let equalityConstraints: [Assign] = []

            let expectedLocation: Vector = [0.0, 0.0]

            guard let objective = SymbolicObjective(
                min: obj,
                subjectTo: constraints,
                equalityConstraints: equalityConstraints
            ) else {
                print("Unable to construct symbolic objective")
                XCTFail("Unable to construct symbolic objective for \(obj)")
                return
            }

            var solver = Solver()
            solver.hyperParameters.residualEpsilon = 1e-8
            let (_, pt, _) = try solver.infeasibleInequalityMinimize(objective: objective)

            XCTAssertTrue(
                pt.isApprox(expectedLocation, within: 0.1),
                "Calculate min location \(pt) is not equal to the expected one \(expectedLocation)"
            )
        } catch {
            print(error)
            XCTFail("Unexpected error thrown")
        }
    }

    /// Benchmark reference: http://benchmarkfcns.xyz/benchmarkfcns/mccormickfcn.html
    ///
    /// Not convex despite what the reference claims. Has local minimums.
    ///
    /// $$f(x, y)=sin(x + y) + (x - y) ^2 - 1.5x + 2.5 y + 1$$
    ///
    func testMcCormick() {
        do {
            let x = Variable("x")
            let y = Variable("y")

            let obj: Node = Sin(x + y) + (x - y) ** 2 - 1.5 * x + 2.5 * y + 1
            let constraints: SymbolicVector = []
            let equalityConstraints: [Assign] = []
            let startPoint: Vector = [-1.0, -1.0]

            let expectedLocation: Vector = [-0.547, -1.547]

            guard let objective = SymbolicObjective(
                min: obj,
                subjectTo: constraints,
                equalityConstraints: equalityConstraints,
                startPrimal: startPoint
            ) else {
                print("Unable to construct symbolic objective")
                XCTFail("Unable to construct symbolic objective for \(obj)")
                return
            }

            var solver = Solver()
            solver.hyperParameters.residualEpsilon = 1e-8
            let (_, pt, _) = try solver.infeasibleInequalityMinimize(objective: objective)

            XCTAssertTrue(
                pt.isApprox(expectedLocation, within: 0.1),
                "Calculate min location \(pt) is not equal to the expected one \(expectedLocation)"
            )
        } catch {
            print(error)
            XCTFail("Unexpected error thrown")
        }
    }

    static var allTests = [
        ("Symbolic Benchmark Booth", testBooth),
        ("Symbolic Benchmark Brent", testBrent),
        ("Symbolic Benchmark Matyas", testMatyas),
        ("Symbolic Benchmark McCormick", testMcCormick),
    ]
}
