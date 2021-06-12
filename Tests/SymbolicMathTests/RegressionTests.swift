import XCTest
import SymbolicMath
import LASwift
import Collections

final class RegressionTests: XCTestCase {

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

    func testRegression1() {
        do {
            // (Sin(angle[t-1])/(k*(cartMass+poleMass)*poleLength - poleMass*poleLength*Power(Cos(angle[t-1]), Number(2)))).taylorExpand(in: angle[t-1], about: previousAngle[t], ofOrder: 1)!
            let angle = Variable("a")
            let previousAngle = Parameter("ap")
            let poleLength = Parameter("poleLength")

            // This was causing a segfault because of recursion, so if it doesn't crash, then it passes
            guard let _ = (poleLength - Cos(angle)).taylorExpand(in: angle, about: previousAngle, ofOrder: 1) else {
                XCTFail("I mean, it apparently didn't crash, but the result shouldn't be optional either.")
                return
            }
        }
    }

    static var allTests = [
        ("Symbolic Math Regression 1", testRegression1)
    ]
}
