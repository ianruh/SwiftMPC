// Created 2020 github @ianruh

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SwiftMPCTests.allTests),
        testCase(RegressionTests.allTests),
        testCase(BenchmarkTests.allTests),
        testCase(UnitTests.allTests),
    ]
}
#endif
