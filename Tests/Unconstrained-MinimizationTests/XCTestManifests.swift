import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Unconstrained_MinimizationTests.allTests),
    ]
}
#endif
