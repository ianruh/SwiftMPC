//
//  File.swift
//  
//
//  Created by Ian Ruh on 5/14/20.
//

import Numerics

//############################ Protocol and Precendence Definitions ##################

public enum OperationAssociativity {
    case left, none, right
}

public enum OperationType {
    case prefix, infix, postfix, function
}

/// Operation precedence struct.
public class OperationPrecedence: Comparable {
    var higherThan: OperationPrecedence?
    
    init(higherThan: OperationPrecedence?) {
        self.higherThan = higherThan
    }
    
    public func getLevel() -> Int {
        var count: Int = 0
        var current: OperationPrecedence = self
        while(current.higherThan != nil) {
            count += 1
            current = current.higherThan!
        }
        return count
    }
    
    public static func < (lhs: OperationPrecedence, rhs: OperationPrecedence) -> Bool {
        return lhs.getLevel() < rhs.getLevel()
    }
    
    public static func == (lhs: OperationPrecedence, rhs: OperationPrecedence) -> Bool {
        return lhs.getLevel() == rhs.getLevel()
    }
}

/// The basic properties all opertaions need to have (plus a factory function)
public protocol Operation: Node {
    var precedence: OperationPrecedence {get}
    var type: OperationType {get}
    var associativity: OperationAssociativity {get}
    var identifier: String {get}
    
    init(_ params: [Node])
    init()
}

extension Operation {
    init(_ params: Node...) {
        self.init(params)
    }
}
