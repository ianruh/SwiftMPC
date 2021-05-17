import XCTest

import MinimizationTests
import MinimizationRegressionTests

var tests = [XCTestCaseEntry]()
tests += MinimizationTests.allTests()
tests += RegressionTests.allTests()
tests += BenchmarkTests.allTests()
XCTMain(tests)
