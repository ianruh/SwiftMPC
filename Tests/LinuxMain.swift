import XCTest

import MinimizationTests
import SymbolicMathTests

var tests = [XCTestCaseEntry]()
tests += MinimizationTests.allTests()
tests += SymbolicMathTests.allTests()
XCTMain(tests)
