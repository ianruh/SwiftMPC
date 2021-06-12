import XCTest
import Collections
import LASwift
import SymbolicMath
import SwiftMPC

/// Tests to do:
/// -[ ] One variable, no constraints
/// -[ ] One variable inequallity
/// -[ ] One variable equality
/// -[ ] One variable ineqaulity and equality
/// -[ ] Three variable, no constraints
/// -[ ] Three variable inequallity
/// -[ ] Three variable equality
/// -[ ] Three variable ineqaulity and equality
/// -[ ] Three varaible with unused variable in inequality
/// -[ ] Three variable with unused variable in equality
/// -[ ] Three variable with unused in all constraints
/// -[ ] Three variable literal starting point
/// -[ ] Three variable infeasible starting point
/// -[ ] Three variable literal equality matrices
/// -[ ] Incomplete ordering
/// -[ ] Random ordering

final class SwiftMPCTests: XCTestCase {

    func testConstrainedMinimization1() {
        
    }

    static var allTests = [
        ("Constrained Minimization 1", testConstrainedMinimization1),
    ]
}
