import XCTest
import SymbolicMath

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
        let two: Number = Number(2.0)
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

    static var allTests = [
        ("Leveling Test", testLeveling),
        ("Rational Simplifying", testRationalSimplifying),
        ("Number Combining", testNumberCombining),
        ("Equality", testEquality),
        ("Combine Like", testCombineLike),
        ("Identities", testIdentities)
    ]
}
