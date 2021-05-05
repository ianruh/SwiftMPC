//
//  File.swift
//  
//
//  Created by Ian Ruh on 5/15/20.
//

import RealModule

//######################### Define the protocol #########################

/**
 Protocol for a function. Example of the properties:
 */
public protocol Function: Operation {
    var numArguments: Int {get}
}

extension Function {

    public var precedence: OperationPrecedence {
        OperationPrecedence(higherThan: Factorial().precedence)
    }
    public var type: OperationType {
        .function
    }
    public var associativity: OperationAssociativity {
        .none
    }
}