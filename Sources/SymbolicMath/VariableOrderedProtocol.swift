//
// Created by Ian Ruh on 5/11/21.
//
import Collections

public protocol VariableOrdered {
    var variables: Set<Variable> { get }

    var _ordering: OrderedSet<Variable>? { get set }
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

    mutating func setVariableOrder<C>(_ newOrdering: C) throws where C: Collection, C.Element == Variable {
        // Make sure every variable in the node is in the ordering
        let variables = self.variables

        for variable in variables {
            guard newOrdering.contains(variable) else {
                throw SymbolicMathError.misc("Ordering must contain all all variables, including \(variable)")
            }
        }

        self._ordering = OrderedSet<Variable>(newOrdering)
    }
}