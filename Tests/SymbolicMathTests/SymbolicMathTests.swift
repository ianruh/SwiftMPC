import XCTest
import SymbolicMath
import LASwift
import Collections

final class SymbolicMathTests: XCTestCase {

    func assertNodesEqual(_ node1: Node?, _ node2: Node, file: StaticString = #file, line: UInt = #line) {
        if let node1n = node1 {
            let n1s = node1n.simplify()
            let n2s = node2.simplify()
            if(!(n1s == n2s)) {
                XCTFail("'\(n1s)' is not equal to '\(n2s)'. Simplified from '\(node1n)' and '\(node2)'.")
            }
        } else {
            XCTFail("node1 was nil")
        }

    }

    func testLeveling() {
        let x = Variable("x")
        let y = Variable("y")
        let exp1 = x*x*x
        let res1 = x**3
        assertNodesEqual(exp1, res1)

        let exp2 = x+y+x
        let res2 = 2*x + y
        assertNodesEqual(exp2, res2)

        let exp3 = (x*x)*(x*x)
        let res3 = x**4
        assertNodesEqual(exp3, res3)

        let exp4 = (x*x)*(x*x)+(y+y+(y+y))
        let res4 = x**4 + 4*y
        assertNodesEqual(exp4, res4)
    }

    func testRationalSimplifying() {
        let x = Variable("x")
        let y = Variable("y")
        let z = Variable("z")
        let a = Variable("a")
        let b = Variable("b")
        let c = Variable("c")

        let exp1 = x/(y/z)
        let res1 = (x*z)/y
        assertNodesEqual(exp1, res1)

        let exp2 = (x/y)/z
        let res2 = x/(y*z)
        assertNodesEqual(exp2, res2)

        let exp3 = (x/z)/(y/z)
        let res3 = (x*z)/(z*y)
        assertNodesEqual(exp3, res3)

        let exp4 = x*(y/z)*(a/b)*c
        let res4 = (x*y*a*c)/(z*b)
        assertNodesEqual(exp4, res4)
    }

    func testNumberCombining() {
        let one: Number = Number(1.0)
        let two: Number = Number(2.0)
        let three: Number = Number(3.0)

        let exp1 = one+two+three
        let res1 = Number(6)
        assertNodesEqual(exp1, res1)

        let exp2 = three-two-one
        let res2 = Number(0)
        assertNodesEqual(exp2, res2)

        let exp3 = three*two*one
        let res3 = Number(6.0)
        assertNodesEqual(exp3, res3)

        let exp4 = Divide(three,two)
        let res4 = Number(1.5)
        assertNodesEqual(exp4, res4)

        let exp5 = Power(two, three)
        let res5 = Number(8.0)
        assertNodesEqual(exp5, res5)
    }

    func testEquality() {
        let one: Number = Number(1.0)
        let three: Number = Number(3.0)
        let x = Variable("x")
        let y = Variable("y")
        let z = Variable("z")

        assertNodesEqual(x, x)

        assertNodesEqual(x+x, x+x)

        assertNodesEqual(y-x, -1*x+y)

        assertNodesEqual(z*y*x, x*y*z)

        assertNodesEqual(one, one)

        assertNodesEqual(one*three, three)
    }

    func testCombineLike() {
        let x = Variable("x")
        let y = Variable("y")

        assertNodesEqual(x*x, Power(x, Number(2)))
        assertNodesEqual(x*Power(x, Number(2)), Power(x, Number(3)))
        assertNodesEqual(x*Power(x, y), Power(x, Number(1) + y))
        assertNodesEqual(x*x*x, Power(x, Number(3)))

        assertNodesEqual(x+x+x, 3*x)
    }

    func testIdentities() {
        let x = Variable("x")

        assertNodesEqual(Number(0)*x, Number(0))
        assertNodesEqual(Number(1)*x, x)

        assertNodesEqual(Number(0)+x, x)
    }

    func testCos() {
        do {
            let x = Variable("x")
            let exp = Cos(x)
            XCTAssertTrue(try exp.evaluate(withValues: [x: 0.0]).isApprox(1.0))
            XCTAssertTrue(try exp.evaluate(withValues: [x: Double.pi / 2]).isApprox(0.0))
            XCTAssertTrue(try exp.evaluate(withValues: [x: Double.pi]).isApprox(-1.0))
        }
    }

    func testSin() {
        do {
            let x = Variable("x")
            let exp = Sin(x)
            XCTAssertTrue(try exp.evaluate(withValues: [x: 0.0]).isApprox(0.0))
            XCTAssertTrue(try exp.evaluate(withValues: [x: Double.pi / 2]).isApprox(1.0))
            XCTAssertTrue(try exp.evaluate(withValues: [x: Double.pi]).isApprox(0.0))
        }
    }

    func testTan() {
        do {
            let x = Variable("x")
            let exp = Tan(x)
            XCTAssertTrue(try exp.evaluate(withValues: [x: 0.0]).isApprox(0.0))
            XCTAssertTrue(try exp.evaluate(withValues: [x: Double.pi]).isApprox(0.0))
            XCTAssertTrue(try exp.evaluate(withValues: [x: Double.pi/4]).isApprox(1.0))
        }
    }

    func testLn() {
        do {
            let x = Variable("x")
            let exp = Ln(x)
            XCTAssertTrue(try exp.evaluate(withValues: [x: 1.0]).isApprox(0.0))
            XCTAssertTrue(try exp.evaluate(withValues: [x: 2.7182818285]).isApprox(1.0))
            XCTAssertTrue(try exp.evaluate(withValues: [x: 20.0]).isApprox(2.9957322736))
        }
    }

    func testSqrt() {
        do {
            let x = Variable("x")
            let exp = Sqrt(x)
            XCTAssertTrue(try exp.evaluate(withValues: [x: 1.0]).isApprox(1.0))
            XCTAssertTrue(try exp.evaluate(withValues: [x: 4.0]).isApprox(2.0))
            XCTAssertTrue(try exp.evaluate(withValues: [x: 10.0]).isApprox(3.1622776602))
        }
    }

    func testNodeHashable() {
        let x = Variable("x")
        let y = Variable("y")

        let one = Number(1)
        let two = Number(2)

        let sin = Sin(x)
        let cos = Cos(x)
        let der = Derivative(of: x,  wrt: y)
        let der2 = Derivative(of: y,  wrt: x)

        var dict: Dictionary<Node, Bool> = [:]
        dict[x] = true
        dict[one] = true
        dict[sin] = true
        dict[der] = true

        XCTAssertNil(dict[y])
        XCTAssertNil(dict[two])
        XCTAssertNil(dict[cos])
        XCTAssertNil(dict[der2])

        XCTAssertNotNil(dict[x])
        XCTAssertNotNil(dict[one])
        XCTAssertNotNil(dict[sin])
        XCTAssertNotNil(dict[der])
    }

    func testReplace() {
        let x = Variable("x")
        let y = Variable("y")
        let z = Variable("z")

        let exp1 = y+y
        let res1 = (x+x).replace(x, with: y)
        assertNodesEqual(exp1, res1)

        let exp2 = y
        let res2 = (x*x).replace(x*x, with: y)
        assertNodesEqual(exp2, res2)

        let exp3 = z
        let res3 = Derivative(of: x, wrt: y).replace(Derivative(of: x, wrt: y), with: z)
        assertNodesEqual(exp3, res3)
    }

    func testGradient() {

        do {
            let x = Variable("x")
            let y = Variable("y")
            let z = Variable("z")
            let eq = x**2 + y**2 + z**2
            guard let gradient = eq.gradient() else {
                XCTFail("Gradient of \(eq) was nil")
                return
            }
            do {
                let gradValue = try gradient.evaluate(withValues: [x: 1.0, y: 1.0, z: 1.0])
                gradValue.forEach({ value in
                    XCTAssertTrue(value.isApprox(2.0), "Element of grdient of \(eq) was not 1 at unity: \(value)")
                })
            } catch {
                XCTFail("Exception thrown: \(error)")
            }
        }

        do {
            let x = Variable("x")
            let y = Variable("y")
            let z = Variable("z")

            var eq = 3*x**2 + 2*y**2 + z**2
            eq.setVariableOrder([x, y, z])

            let expectedGradient: Vector = [6.0, 4.0, 2.0]

            guard let symbolicGradient = eq.gradient() else {
                XCTFail("Failed to compute gradient of \(eq)")
                return
            }

            XCTAssertEqual(expectedGradient, try symbolicGradient.evaluate(withValues: [x: 1.0, y: 1.0, z: 1.0]))
        }

        do {
            let x = Variable("x")
            let y = Variable("y")
            let z = Variable("z")

            var eq = x - y
            eq.setVariableOrder([x, y, z])

            let expectedGradient: Vector = [1.0, -1.0, 0.0]

            guard let symbolicGradient = eq.gradient() else {
                XCTFail("Failed to compute gradient of \(eq)")
                return
            }

            XCTAssertEqual(expectedGradient, try symbolicGradient.evaluate(withValues: [x: 1.0, y: 1.0, z: 1.0]))
        }

    }

    func testHessian() {
        do {
            let x = Variable("x")
            let y = Variable("y")
            let z = Variable("z")
            let eq = x**2 + y**2 + z**2

            let expectedHessian = Matrix([
                [2.0, 0.0, 0.0],
                [0.0, 2.0, 0.0],
                [0.0, 0.0, 2.0]
            ])

            guard let hessian = eq.hessian() else {
                XCTFail("Hessian of \(eq) was nil")
                return
            }

            do {
                let hessianValue = try hessian.evaluate(withValues: [x: 1.0, y: 1.0, z: 1.0]) // Values don't actually matter
                XCTAssertEqual(expectedHessian, hessianValue, "Returned Hessian did not match expected Hessian: \(hessianValue), \(expectedHessian)")
            } catch {
                XCTFail("Exception thrown: \(error)")
            }
        }
    }

    func testOrdering() {
        let x = Variable("x")
        let y = Variable("y")
        let z = Variable("z")

        var eq = 3*x**2 + 2*y**2 + z**2

        do {
            let ordering: OrderedSet<Variable> = [x, y, z]
            let evalPoint: Vector = [1.0, 1.0, 1.0]
            eq.setVariableOrder(ordering)

            let expectedGradient: Vector = [6.0, 4.0, 2.0]
            let expectedHessian = Matrix([
                [6.0, 0.0, 0.0],
                [0.0, 4.0, 0.0],
                [0.0, 0.0, 2.0]
            ])

            guard let symbolicGradient = eq.gradient() else {
                XCTFail("Failed to compute gradient of \(eq)")
                return
            }

            guard let symbolicHessian = eq.hessian() else {
                XCTFail("Failed to compute hessian of \(eq)")
                return
            }

            XCTAssertEqual(expectedGradient, try symbolicGradient.evaluate(evalPoint))
            XCTAssertEqual(expectedHessian, try symbolicHessian.evaluate(evalPoint))

            // Verify child orderings
            XCTAssertEqual(symbolicGradient.orderedVariables, ordering)
            XCTAssertEqual(symbolicHessian.orderedVariables, ordering)
            symbolicGradient.forEach({ XCTAssertEqual($0.orderedVariables, ordering) })
            symbolicHessian.forEach({ XCTAssertEqual($0.orderedVariables, ordering) })
            symbolicHessian.forEach({ vector in
                vector.forEach({ XCTAssertEqual($0.orderedVariables, ordering) })
            })
        }

        do {
            let ordering: OrderedSet<Variable> = [z, y, x]
            let evalPoint: Vector = [1.0, 1.0, 1.0]
            eq.setVariableOrder(ordering)

            let expectedGradient: Vector = [2.0, 4.0, 6.0]
            let expectedHessian = Matrix([
                [2.0, 0.0, 0.0],
                [0.0, 4.0, 0.0],
                [0.0, 0.0, 6.0]
            ])

            guard let symbolicGradient = eq.gradient() else {
                XCTFail("Failed to compute gradient of \(eq)")
                return
            }

            guard let symbolicHessian = eq.hessian() else {
                XCTFail("Failed to compute hessian of \(eq)")
                return
            }

            XCTAssertEqual(expectedGradient, try symbolicGradient.evaluate(evalPoint))
            XCTAssertEqual(expectedHessian, try symbolicHessian.evaluate(evalPoint))

            // Verify child orderings
            XCTAssertEqual(symbolicGradient.orderedVariables, ordering)
            XCTAssertEqual(symbolicHessian.orderedVariables, ordering)
            symbolicGradient.forEach({ XCTAssertEqual($0.orderedVariables, ordering) })
            symbolicHessian.forEach({ XCTAssertEqual($0.orderedVariables, ordering) })
            symbolicHessian.forEach({ vector in
                vector.forEach({ XCTAssertEqual($0.orderedVariables, ordering) })
            })
        }

        do {
            eq = x**2
            let ordering: OrderedSet<Variable> = [y, x, z]
            let evalPoint: Vector = [1.0, 1.0, 1.0]
            eq.setVariableOrder(ordering)

            let expectedGradient: Vector = [0.0, 2.0, 0.0]
            let expectedHessian = Matrix([
                [0.0, 0.0, 0.0],
                [0.0, 2.0, 0.0],
                [0.0, 0.0, 0.0]
            ])

            guard let symbolicGradient = eq.gradient() else {
                XCTFail("Failed to compute gradient of \(eq)")
                return
            }

            guard let symbolicHessian = eq.hessian() else {
                XCTFail("Failed to compute hessian of \(eq)")
                return
            }

            XCTAssertEqual(expectedGradient, try symbolicGradient.evaluate(evalPoint))
            XCTAssertEqual(expectedHessian, try symbolicHessian.evaluate(evalPoint))

            // Verify child orderings
            XCTAssertEqual(symbolicGradient.orderedVariables, ordering)
            XCTAssertEqual(symbolicHessian.orderedVariables, ordering)
            symbolicGradient.forEach({ XCTAssertEqual($0.orderedVariables, ordering) })
            symbolicHessian.forEach({ XCTAssertEqual($0.orderedVariables, ordering) })
            symbolicHessian.forEach({ vector in
                vector.forEach({ XCTAssertEqual($0.orderedVariables, ordering) })
            })

        }
    }


    static var allTests = [
        ("Leveling Test", testLeveling),
        ("Rational Simplifying", testRationalSimplifying),
        ("Number Combining", testNumberCombining),
        ("Equality", testEquality),
        ("Combine Like", testCombineLike),
        ("Identities", testIdentities),
        ("Cosine", testCos),
        ("Sine", testSin),
        ("Tangent", testTan),
        ("Natural Log", testLn),
        ("Square Root", testSqrt),
        ("Node Hashable", testNodeHashable),
        ("Replace", testReplace),
        ("Gradient", testGradient),
        ("Hessian", testHessian),
        ("Variable Ordering", testOrdering)
    ]
}
