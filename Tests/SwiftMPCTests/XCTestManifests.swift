import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SwiftMPCTests.allTests),
        testCase(RegressionTests.allTests),
        testCase(BenchmarkTests.allTests)
    ]
}
#endif
