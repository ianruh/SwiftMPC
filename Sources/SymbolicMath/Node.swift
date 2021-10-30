// Created 2020 github @ianruh

import LASwift
import OrderedCollections

public class Node: CustomStringConvertible, Comparable, Hashable, CustomDebugStringConvertible {
    // ------------------------ Properties ------------------------

    /// The node's unqie identifier
    public lazy var id = Id()

    private var _ordering: OrderedSet<Variable>?

    /// The node's ordering of the variables. It uses the default ordering, unless one is
    /// set using the `setOrdering` method. This should not be assigned to.
    /// TODO: Refactor to remove the set option here.
    public var orderedVariables: OrderedSet<Variable> {
        get {
            if let ordering = self._ordering {
                return ordering
            } else {
                let simpleOrdering = OrderedSet<Variable>(self.variables.sorted())
                self._ordering = simpleOrdering
                return simpleOrdering
            }
        }
        set {
            self._ordering = newValue
        }
    }

    /// For CustomDebugStringConvertible
    public var debugDescription: String {
        return self.description
    }

    /// A string representation of the node. This should be overridden.
    public var description: String {
        preconditionFailure("description should be overridden")
    }

    /// A latex representation of the node. This should be overridden.
    public var latex: String {
        preconditionFailure("latex should be overridden")
    }

    /// The set of variables in the node. This should be overridden.
    internal var _variables: Set<Variable>?
    public var variables: Set<Variable> {
        if let variables = self._variables {
            return variables
        } else {
            return []
        }
    }

    /// The set of variables in the node. This should be overridden.
    internal var _parameters: Set<Parameter>?
    public var parameters: Set<Parameter> {
        if let parameter = self._parameters {
            return parameter
        } else {
            return []
        }
    }

    /// The set of binary variables in the node. This should be overridden.
    internal var _binaryVariables: Set<BinaryVariable>?
    public var binaryVariables: Set<BinaryVariable> {
        if let binaryVariable = self._binaryVariables {
            return binaryVariable
        } else {
            return []
        }
    }

    /// The set of derivatives in the node. This should be overridden.
    public var derivatives: Set<Derivative> {
        preconditionFailure("derivatives should be overridden")
    }

    /// The type identifier of the class. This should be overridden.
    public var typeIdentifier: String {
        preconditionFailure("typeIdentifier should be overridden")
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

    internal var isSimplified: Bool = false

    // ------------------------ Functions ------------------------

    /// Set the variable ordering of the node
    /// - Parameter newOrdering: The new ordering of variables
    /// - Throws: If the new ordering does not contain all variables in the node
    ///
    /// The new ordering may contain more than the variables in just this node.
    public func setVariableOrder<C>(_ newOrdering: C) throws where C: Collection,
        C.Element == Variable
    {
        try self.variables.forEach { variable in
            guard newOrdering.contains(variable) else {
                throw SymbolicMathError
                    .misc("New ordering \(newOrdering) does not contain variable \(variable).")
            }
        }
        self.orderedVariables = OrderedSet<Variable>(newOrdering)
    }

    /// Set the variable order by inheriting it from another node.
    /// - Parameter node: The node to inherit the order from.
    /// - Throws: If the new node contains variable(s) not in the progenitor node.
    public func setVariableOrder(from node: Node) throws {
        if let ordering = node._ordering {
            try self.setVariableOrder(ordering)
        }
    }

    /// Evaluate the node. This should be overridden.
    public func evaluate(withValues _: [Node: Double]) throws -> Double {
        preconditionFailure("This method must be overridden")
    }

    /// Evaluate the node using a given set of variable and parameter values.
    /// - Parameters:
    ///   - x: A vector (with the values in the order of the node's variable ordering) containing the values for the variables.
    ///   - parameterValues: The values of the parameters to evaluate at.
    /// - Throws: If the node cannot be evaluated (e.g. if not all variables or parameter's are given values).
    /// - Returns: The value of the node at the given location.
    public func evaluate(_ x: Vector,
                         withParameters parameterValues: [Parameter: Double] = [:]) throws -> Double
    {
        // Ensure the vector is the right length
        guard x.count == self.orderedVariables.count else {
            throw SymbolicMathError
                .misc(
                    "Vector \(x) is the wrong length (\(x.count) != \(self.orderedVariables.count)"
                )
        }

        // We don't check that all parameters are represented. It will throw a clear error if one is missing when
        // it tries to evaluate it.

        var values = [Node: Double]()
        let orderedVariables = self.orderedVariables
        for i in 0 ..< x.count {
            values[orderedVariables[i]] = x[i]
        }

        // merge in the parameters. The closure is meaningless, as there will never be conflicting
        // keys in this case (only variables present in values, and only parameters present in
        // parameterValues).
        values.merge(parameterValues, uniquingKeysWith: { current, _ in current })

        return try self.evaluate(withValues: values)
    }

    /// Function returns whether the other node logically equals this function
    /// Note that this assumes both sides are simplified already, so it doesn't
    /// call simplify itself.
    internal func equals(_: Node) -> Bool {
        preconditionFailure("This method must be overridden")
    }

    /// Get the count of how many of the given elements are in the node.
    ///
    /// - Parameter nodeType: Type interested in
    /// - Returns: The number found.
    public func contains<T: Node>(nodeType _: T.Type) -> [Id] {
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
    @discardableResult public func replace(_: Node, with _: Node) -> Node {
        preconditionFailure("This method must be overridden.")
    }

    /// Get the node with the given id.
    ///
    /// - Parameter id: Id of the node to get.
    /// - Returns: The node with the given id, if it exists in the tree.
    public func getNode(withId _: Id) -> Node? {
        preconditionFailure("This method must be overridden")
    }

    /// Simplify the node
    ///
    /// - Returns: The simplified node, or the same node if no simplification has been performed.
    public func simplify() -> Node {
        preconditionFailure("This method must be overridden")
    }

    /// Has of the node. Does not simplify  the node, so is dependent on the node structure.
    /// - Parameter : The hasher to hash into.
    public func hash(into _: inout Hasher) {
        preconditionFailure("This method must be overriden")
    }

    /// A Swift representation of the node value. This should be overridden.
    /// It is really f******* verbose (lots of parenthesis)
    /// Assumes access to swift-numerics real module
    public func swiftCode(using _: [Node: String]) throws -> String {
        preconditionFailure("This method must be overriden")
    }

    /// Taylor expand the node.
    ///
    /// - Parameters:
    ///   - variable: The variable to taylor expand in (may be any node).
    ///   - location: The location to taylor expand around (may be  any node).
    ///   - order: The order of the taylor expansion.
    /// - Returns: The taylor expansion of the node if it can be found. May return nil if a deriavtive could not be calculated.
    public func taylorExpand(in variable: Node, about location: Node, ofOrder order: Int) -> Node? {
        // Check that the order is positive
        guard order >= 0 else {
            return nil
        }

        var terms: Node = Number(0)
        var derivatives: [Node] = [self]
        for i in 0 ... order {
            terms = terms + derivatives.last!.replace(variable, with: location) /
                Number(i.factorial()) * (variable - location) ** Number(i)
            // Find the ith derivative
            guard let nextDerivative = differentiate(derivatives.last!, wrt: variable) else {
                return nil
            }
            derivatives.append(nextDerivative)
        }

        return terms
    }

    // --------------Comparable Conformance-----------------

    /// Determine if two nodes are equal (without simplifying, so it is structure dependent)
    /// - Parameters:
    ///   - lhs: Left hand node
    ///   - rhs: Right hand node
    /// - Returns: If the nodes are equal.
    public static func == (_ lhs: Node, _ rhs: Node) -> Bool {
        return lhs.equals(rhs)
    }

    /// Attempt to determine if two nodes are nathematically equal. If they simplify to the same representation, then it will return true.
    /// - Parameters:
    ///   - lhs: Left hand node
    ///   - rhs: Right hand node
    /// - Returns: True if the simplification of the nodes are equal.
    public static func ~= (_ lhs: Node, _ rhs: Node) -> Bool {
        return lhs.simplify() == rhs.simplify()
    }

    /// Only does a cursory comparison of types. Will be correct for numbers and variables,
    /// but otherwise only compares the types of the nodes.
    ///
    /// Opertions < Variables < Numbers
    public static func < (_ lhs: Node, _ rhs: Node) -> Bool {
        if lhs.isOperation, rhs.isOperation {
            return lhs.typeIdentifier < rhs.typeIdentifier
        } else if lhs.isOperation, rhs.isBasic {
            return true
        } else if lhs.isBasic, rhs.isOperation {
            return false
        } else if lhs.isVariable, rhs.isVariable {
            return (lhs as! Variable).string < (rhs as! Variable).string
        } else if lhs.isVariable, rhs.isNumber {
            return true
        } else if lhs.isNumber, rhs.isVariable {
            return false
        } else if lhs.isNumber, rhs.isNumber {
            return (lhs as! Number).value < (rhs as! Number).value
        } else {
            // This shouldn't ever run, but just in case
            return lhs.typeIdentifier < rhs.typeIdentifier
        }
    }
}
