import XCTest

import SwiftMPCTests
import SymbolicMathTests

var tests = [XCTestCaseEntry]()
tests += SwiftMPCTests.allTests()
tests += SymbolicMathTests.allTests()
XCTMain(tests)
