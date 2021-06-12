// Created 2020 github @ianruh

import RealModule

// ######################### Define the protocol #########################

/**
 Protocol for a function. Example of the properties:
 */
public protocol Function: Operation {
    var numArguments: Int { get }
}

public extension Function {
    var precedence: OperationPrecedence {
        OperationPrecedence(higherThan: Factorial.staticPrecedence)
    }

    var type: OperationType {
        .function
    }

    var associativity: OperationAssociativity {
        .none
    }
}
