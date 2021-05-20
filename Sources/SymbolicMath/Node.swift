//
//  File.swift
//  
//
//  Created by Ian Ruh on 5/14/20.
//

import OrderedCollections
import LASwift

public class Node: CustomStringConvertible, Comparable, Hashable, VariableOrdered {

    //------------------------ Properties ------------------------

    /// The node's unqie identifier
    lazy public var id: Id = Id()

    public var _ordering: OrderedSet<Variable>? = nil

    /// A string representation of the node. This should be overridden.
    public var description: String {
        preconditionFailure("description should be overridden")
    }

    /// A latex representation of the node. This should be overridden.
    public var latex: String {
        preconditionFailure("latex should be overridden")
    }

    /// The set of variables in the node. This should be overridden.
    public var variables: Set<Variable> {
        preconditionFailure("variables should be overridden")
    }

    /// The set of variables in the node. This should be overridden.
    public var parameters: Set<Parameter> {
        preconditionFailure("parameters should be overridden")
    }

    /// The set of derivatives in the node. This should be overridden.
    public var derivatives: Set<Derivative> {
        preconditionFailure("derivatives should be overridden")
    }

    /// The type identifier of the class. This should be overridden.
    public var typeIdentifier: String {
        preconditionFailure("variables should be overridden")
    }

    /// Determine if the node is basic
    public var isBasic: Bool {
        return self as? Number != nil || self as? Variable != nil
    }

    /// Dertermine if the node is a variable
    public var isVariable: Bool {
        return self as? Variable != nil
    }

    /// Dertermine if the node is a variable
    public var isNumber: Bool {
        return self as? Number != nil
    }

    /// Determine if the node is an operation
    public var isOperation: Bool {
        return self as? Operation != nil
    }

    /// Determine is the node is a function
    public var isFunction: Bool {
        return self as? Function != nil
    }

    //------------------------ Functions ------------------------

    public func setVariableOrder<C>(_ newOrdering: C) where C: Collection, C.Element == Variable {
        self._ordering = OrderedSet<Variable>(newOrdering)
    }

    /// Evaluate the node. This should be overridden.
    public func evaluate(withValues values: [Node: Double]) throws -> Double {
        preconditionFailure("This method must be overridden")
    }

    public func evaluate(_ x: Vector) throws -> Double {
        // Ensure the vector is the right length
        guard x.count == self.orderedVariables.count else {
            throw SymbolicMathError.misc("Vector \(x) is the wrong length (\(x.count) != \(self.orderedVariables.count)")
        }

        var values = Dictionary<Node, Double>()
        let orderedVariables = self.orderedVariables
        for i in 0..<x.count {
            values[orderedVariables[i]] = x[i]
        }
        return try self.evaluate(withValues: values)
    }

    /// Function returns whether the other node logically equals this function
    /// Note that this assumes both sides are simplified already, so it doesn't
    /// call simplify itself.
    internal func equals(_ otherNode: Node) -> Bool {
        preconditionFailure("This method must be overridden")
    }

    /// Get the count of how many of the given elements are in the node.
    ///
    /// - Parameter nodeType: Type interested in
    /// - Returns: The number found.
    public func contains<T: Node>(nodeType: T.Type) -> [Id] {
        preconditionFailure("This method must be overridden")
    }

    /// Replace the node with the given id with another node.
    ///
    /// - Parameters:
    ///   - id: The ID of the node to be replaced.
    ///   - replacement: The replacement node.
    /// - Returns: Returns true if the node was replaced, and false otherwise.
    /// - Throws: If the node cannot be replaced.
    /// Replace a node with another node.
    @discardableResult public func replace(_ targetNode: Node, with replacement: Node) -> Node {
        preconditionFailure("This method must be overridden.")
    }

    /// Get the node with the given id.
    ///
    /// - Parameter id: Id of the node to get.
    /// - Returns: The node with the given id, if it exists in the tree.
    public func getNode(withId id: Id) -> Node? {
        preconditionFailure("This method must be overridden")
    }

    /// Simplify the node
    ///
    /// - Returns: The simplified node, or the same node if no simplification has been performed.
    public func simplify() -> Node {
        preconditionFailure("This method must be overridden")
    }

    public func hash(into hasher: inout Hasher) {
        preconditionFailure("This method must be overriden")
    }

    /// A Swift representation of the node value. This should be overridden.
    /// It is really f******* verbose (lots of parenthesis)
    /// Assumes access to swift-numerics real module
    public func swiftCode(using representations: Dictionary<Node, String>) throws -> String {
        preconditionFailure("This method must be overriden")
    }

    //--------------Comparable Conformance-----------------

    public static func ==(_ lhs: Node, _ rhs: Node) -> Bool {
        return lhs.equals(rhs)
    }

    public static func ~=(_ lhs: Node, _ rhs: Node) -> Bool {
        return lhs.simplify() == rhs.simplify()
    }

    /// Only does a cursory comparison of types. Will be correct for numbers and variables,
    /// nut otherwise only compares the types of the nodes.
    ///
    /// Opertions < Variables < Numbers
    public static func <(_ lhs: Node, _ rhs: Node) -> Bool {
        if(lhs.isOperation && rhs.isOperation) {
            return lhs.typeIdentifier < rhs.typeIdentifier
        } else if(lhs.isOperation &&  rhs.isBasic) {
            return true
        } else if(lhs.isBasic && rhs.isOperation) {
            return false
        } else if(lhs.isVariable && rhs.isVariable) {
            return (lhs as! Variable).string < (rhs as! Variable).string
        } else if(lhs.isVariable && rhs.isNumber) {
            return true
        } else if(lhs.isNumber && rhs.isVariable) {
            return false
        } else if(lhs.isNumber && rhs.isNumber) {
            return (lhs as! Number).value < (rhs as! Number).value
        } else {
            // This shouldn't ever run, but just in case
            return lhs.typeIdentifier < rhs.typeIdentifier
        }
    }
}