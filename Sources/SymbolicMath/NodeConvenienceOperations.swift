//
// Created by Ian Ruh on 8/29/20.
//
import LASwift

// We have node, variable, and number versions here.

//------------------------- Custom Precedence --------------------

// New precidence for power
precedencegroup ExponentiationPrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}



//------------------------- Custom Operators --------------------

infix operator ** : ExponentiationPrecedence
infix operator .** : ExponentiationPrecedence
infix operator ~ : AssignmentPrecedence
infix operator ≈ : AssignmentPrecedence

//------------------------- Operations --------------------

/// Add operator for nodes
///
/// - Parameters:
///   - lhs: Left side of infix operation
///   - rhs: Right side of infix operation
/// - Returns: New node adding the two
public func +(_ lhs: Node, _ rhs: Node) -> Node {
    if(lhs is Add && rhs is Add) {
        return Add((lhs as! Add).arguments + (rhs as! Add).arguments)
    } else if(lhs is Add) {
        return Add((lhs as! Add).arguments + [rhs])
    } else if(rhs is Add) {
        return Add((rhs as! Add).arguments + [lhs])
    }
    return Add([lhs, rhs])
}
public func +(_ lhs: Node, _ rhs: Number) -> Node {
    if(lhs is Add) {
        return Add((lhs as! Add).arguments + [rhs])
    }
    return Add([lhs, rhs])
}
public func +(_ lhs: Number, _ rhs: Node) -> Node {
    if(rhs is Add) {
        return Add((rhs as! Add).arguments + [lhs])
    }
    return Add([lhs, rhs])
}

/// Subtract operator for nodes
///
/// - Parameters:
///   - lhs:
///   - rhs:
/// - Returns:
public func -(_ lhs: Node, _ rhs: Node) -> Node {
    return Subtract([lhs, rhs])
}
public func -(_ lhs: Node, _ rhs: Number) -> Node {
    return Subtract([lhs, rhs])
}
public func -(_ lhs: Number, _ rhs: Node) -> Node {
    return Subtract([lhs, rhs])
}

/// Divide operator for nodes
///
/// - Parameters:
///   - lhs:
///   - rhs:
/// - Returns:
public func /(_ lhs: Node, _ rhs: Node) -> Node {
    return Divide([lhs, rhs])
}
public func /(_ lhs: Node, _ rhs: Number) -> Node {
    return Divide([lhs, rhs])
}
public func /(_ lhs: Number, _ rhs: Node) -> Node {
    return Divide([lhs, rhs])
}

/// Multiply operator for nodes
///
/// - Parameters:
///   - lhs:
///   - rhs:
/// - Returns:
public func *(_ lhs: Node, _ rhs: Node) -> Node {
    if(lhs is Multiply && rhs is Multiply) {
        return Multiply((lhs as! Multiply).arguments + (rhs as! Multiply).arguments)
    } else if(lhs is Multiply) {
        return Multiply((lhs as! Multiply).arguments + [rhs])
    } else if(rhs is Multiply) {
        return Multiply((rhs as! Multiply).arguments + [lhs])
    }
    return Multiply([lhs, rhs])
}
public func *(_ lhs: Node, _ rhs: Double) -> Node {
    if(lhs is Multiply) {
        return Multiply((lhs as! Multiply).arguments + [Number(rhs)])
    }
    return Multiply(lhs, Number(rhs))
}
public func *(_ lhs: Double, _ rhs: Node) -> Node {
    if(rhs is Multiply) {
        return Multiply((rhs as! Multiply).arguments + [Number(lhs)])
    }
    return Multiply(Number(lhs), rhs)
}

/// Take the lhs to the power of the rhs
///
/// - Parameters:
///   - lhs:
///   - rhs:
/// - Returns:
public func **(_ lhs: Node, _ rhs: Node) -> Node {
    return Power([lhs, rhs])
}
public func **(_ lhs: Node, _ rhs: Number) -> Node {
    return Power([lhs, rhs])
}
public func **(_ lhs: Number, _ rhs: Node) -> Node {
    return Power([lhs, rhs])
}

/// Assign the lhs to the  rhs
///
/// - Parameters:
///   - lhs:
///   - rhs:
/// - Returns:
public func ~(_ lhs: Node, _ rhs: Node) -> Assign {
    return Assign([lhs, rhs])
}
public func ~(_ lhs: Number, _ rhs: Node) -> Assign {
    return Assign([lhs, rhs])
}
public func ~(_ lhs: Node, _ rhs: Number) -> Assign {
    return Assign([lhs, rhs])
}

public func ≈(_ lhs: Node, _ rhs: Node) -> Assign {
    return Assign([lhs, rhs])
}
public func ≈(_ lhs: Number, _ rhs: Node) -> Assign {
    return Assign([lhs, rhs])
}
public func ≈(_ lhs: Node, _ rhs: Number) -> Assign {
    return Assign([lhs, rhs])
}

// Comparisons
public func <=(_ lhs: Node, _ rhs: Node) -> Node {
    return Subtract(lhs, rhs)
}
public func <=(_ lhs: Number, _ rhs: Node) -> Node {
    return Subtract(lhs, rhs)
}
public func <=(_ lhs: Node, _ rhs: Number) -> Node {
    return Subtract(lhs, rhs)
}
public func >=(_ lhs: Node, _ rhs: Node) -> Node {
    return Subtract(rhs, lhs)
}
public func >=(_ lhs: Number, _ rhs: Node) -> Node {
    return Subtract(rhs, lhs)
}
public func >=(_ lhs: Node, _ rhs: Number) -> Node {
    return Subtract(rhs, lhs)
}


public func <=(_ lhs: Double, _ rhs: Node) -> Node {
    return Subtract(lhs.symbol, rhs)
}
public func <=(_ lhs: Node, _ rhs: Double) -> Node {
    return Subtract(lhs, rhs.symbol)
}
public func >=(_ lhs: Double, _ rhs: Node) -> Node {
    return Subtract(rhs, lhs.symbol)
}
public func >=(_ lhs: Node, _ rhs: Double) -> Node {
    return Subtract(rhs.symbol, lhs)
}
