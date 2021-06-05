import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SymbolicMathTests.allTests),
        testCase(RegressionTests.allTests)
    ]
}
#endif
