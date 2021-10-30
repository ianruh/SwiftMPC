import XCTest
import Collections
import LASwift
import SymbolicMath
import SwiftMPC

final class UnitTests: XCTestCase {

    func testBinaryVariableContain() {
        do {
            let x = Variable("x")
            let y = Variable("y")
            let z = Variable("z")

            let b1 = BinaryVariable("b1")
            let b2 = BinaryVariable("b2")

            let exp = x**4 + b1**4 + z**4 / (Ln(b2) + y)

            XCTAssertEqual(exp.binaryVariables, Set([b1, b2]))
        } catch {
            print(error)
            XCTFail("Unnexpected excpetion thrown")
        }
    }
 
    static var allTests = [
        ("Binary Variables in Expression", testBinaryVariableContain),
   ]
}
