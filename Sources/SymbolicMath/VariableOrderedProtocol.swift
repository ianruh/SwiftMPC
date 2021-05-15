//
// Created by Ian Ruh on 5/11/21.
//
import Collections

public protocol VariableOrdered {
    var variables: Set<Variable> { get }

    var _ordering: OrderedSet<Variable>? { get set }

    mutating func setVariableOrder<C>(_ newOrdering: C) where C: Collection, C.Element == Variable
}

public extension VariableOrdered {
    // Variable Ordering
    var orderedVariables: OrderedSet<Variable> {
        guard let ordering = self._ordering else {
            return OrderedSet<Variable>(self.variables.sorted())
        }
        // Ordering doesn't necessarily contain all of the variables, so:
        return ordering.union(self.variables.sorted())
    }
}