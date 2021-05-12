//
// Created by Ian Ruh on 4/23/21.
//

extension Double {

    /**
     Determine if a double is approximately equal to a given number.
     - Parameters:
       - expectedValue: The expected value to be equal to
       - delta: The tolerance in the comparions
     - Returns: True if the value is within the given tolerance
     */
    public func isApprox(_ expectedValue: Double, within delta: Double = 0.0001) -> Bool {
        if(self > expectedValue - delta && self < expectedValue + delta) {
            return true
        } else {
            return false
        }
    }
}