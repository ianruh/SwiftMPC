
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

extension Array where Element == Double {
    /**
     Determine if a double collection is approximately equal to a given collection.
     - Parameters:
       - expectedValue: The expected value to be equal to
       - delta: The tolerance in the comparions
     - Returns: True if the value is within the given tolerance
     */
    public func isApprox(_ expectedValue: [Double], within delta: Double = 0.0001) -> Bool {
        // Check lengths
        guard self.count == expectedValue.count else {
            return false
        }

        // Check each element
        for i in 0..<self.count {
            if(!self[i].isApprox(expectedValue[i], within: delta)) {
                return false
            }
        }

        return true
    }
}