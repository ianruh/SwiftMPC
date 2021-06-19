// Created 2020 github @ianruh

/// Differentiate a given node.
///
/// - Parameters:
///   - term: The term to differentuate.
///   - variable: The variable to differentiate with respect to.
/// - Returns: The derivative, or nil if the derivative could not be found.
public func differentiate(_ term: Node, wrt variableNode: Node, partially: Bool = true) -> Node? {
    guard let variable = variableNode as? Variable else {
        // TODO: Figure out how to do this with matching
        preconditionFailure("Only can take derivative with respect to variables at the moment")
    }

    switch term {
    case let vari as Variable:
        if partially {
            // Take the Partial derivative
            if vari == variable {
                return Number(1)
            } else {
                return Number(0)
            }
        } else {
            // Take the total derivative
            if vari == variable {
                return Number(1)
            } else {
                return Derivative(of: vari, wrt: variable)
            }
        }
    case is Number:
        return Number(0)
    case is Parameter:
        return Number(0)
    case is Assign:
        return nil
    case let negative as Negative:
        if let argDir = differentiate(negative.argument, wrt: variable, partially: partially) {
            return Negative(argDir)
        } else {
            return nil
        }
    case let add as Add:
        var terms: [Node] = []

        for arg in add.arguments {
            if let der = differentiate(arg, wrt: variable, partially: partially) {
                if der != Number(0) {
                    terms.append(der)
                }
            } else {
                return nil
            }
        }

        if terms.count == 0 {
            return Number(0)
        } else if terms.count == 1 {
            return terms[0]
        } else {
            return Add(terms)
        }
    case let sub as Subtract:
        let leftOp = differentiate(sub.left, wrt: variable, partially: partially)
        let rightOp = differentiate(sub.right, wrt: variable, partially: partially)

        guard let left = leftOp else {
            return nil
        }
        guard let right = rightOp else {
            return nil
        }

        if right == Number(0) {
            return leftOp
        } else if left == Number(0) {
            return Negative(right)
        } else {
            return left - right
        }
    case let mul as Multiply:
        var current = BinaryMultiply(mul.arguments[0], mul.arguments[1])
        for i in 2 ..< mul.arguments.count {
            current = BinaryMultiply(mul.arguments[i], current)
        }
        // We do the zero simplification in the  binary multipy derivative function
        return current.derivative(wrt: variable, partially: partially)
    case let div as Divide:
        let leftOp = differentiate(div.left, wrt: variable, partially: partially)
        let rightOp = differentiate(div.right, wrt: variable, partially: partially)

        guard let left = leftOp else {
            return nil
        }
        guard let right = rightOp else {
            return nil
        }

        return (left * div.right - right * div.left) / Power(div.right, Number(2))
    case let pow as Power:
        // This one is a bit ugly, but here it is nicely written out:
        // https://en.wikipedia.org/wiki/Differentiation_rules#Generalized_power_rule

        let dbaseOp = differentiate(pow.left, wrt: variable, partially: partially)
        let dpowerOp = differentiate(pow.right, wrt: variable, partially: partially)

        guard let dbase = dbaseOp else {
            return nil
        }
        guard let dpower = dpowerOp else {
            return nil
        }

        if dbase == Number(0), dpower == Number(0) {
            return Number(0)
        } else if dbase == Number(0) {
            return pow * dpower * Ln([pow.left])
        } else if dpower == Number(0) {
            return pow * (dbase * pow.right / pow.left)
        } else {
            return pow * (dbase * pow.right / pow.left + dpower * Ln([pow.left]))
        }

    // return pow*(dbase*pow.right/pow.left + dpower*Ln([pow.left]))
    case is Factorial:
        return nil
    case let dir as Derivative:
        let dirOne = differentiate(dir.diffOf, wrt: dir.withRespectTo, partially: partially)
        guard let dirOneN = dirOne else {
            return nil
        }
        return differentiate(dirOneN, wrt: variable, partially: partially)
//    case let int as Integral:
//        // TODO: Implement, isn't bad
//        return nil
    case is AbsoluteValue:
        return nil
//    case let erf as ErrorFunction:
//        // TODO: Implement erf derivative
//        return nil
    case let sin as Sin:
        let darg = differentiate(sin.argument, wrt: variable, partially: partially)
        if darg != nil {
            return Cos(sin.argument) * darg!
        } else {
            return nil
        }
    case let cos as Cos:
        let darg = differentiate(cos.argument, wrt: variable, partially: partially)
        if darg != nil {
            return -1 * Sin(cos.argument) * darg!
        } else {
            return nil
        }
    case let tan as Tan:
        let darg = differentiate(tan.argument, wrt: variable, partially: partially)
        if darg != nil {
            return 1 / Power([Cos(tan.argument), Number(2)]) * darg!
        } else {
            return nil
        }
    case let sqrt as Sqrt:
        return differentiate(Power([sqrt.argument, Number(0.5)]), wrt: variable, partially: partially)
    case let exp as Exp:
        let dexp = differentiate(exp.argument, wrt: variable, partially: partially)

        if dexp != nil {
            return exp * dexp!
        } else {
            return nil
        }
    case let log as Ln:
        let dlog = differentiate(log.argument, wrt: variable, partially: partially)

        if dlog != nil {
            return (1 / log.argument) * dlog!
        } else {
            return nil
        }
    default:
        return nil
    }
}

/// This is just a utility to help simplify doing the chain rule.
private struct BinaryMultiply {
    var left: Node
    var right: Node

    init(_ left: Node, _ right: Node) {
        self.left = left
        self.right = right
    }

    init(_ left: Node, _ right: BinaryMultiply) {
        self.left = left
        self.right = Multiply(right.left, right.right)
    }

    /// Function is of the same for as the Node deirvative, so is essenntially interchangable.
    ///
    /// - Parameters:
    ///   - variable: The variable to take the derivative with respect to.
    ///   - partially: Whether to take a full or partial derivative.
    /// - Returns: The derivative, if found.
    func derivative(wrt variable: Node, partially: Bool) -> Node? {
        let dleftOp = differentiate(self.left, wrt: variable, partially: partially)
        let drightOp = differentiate(self.right, wrt: variable, partially: partially)

        guard let dleft = dleftOp else {
            return nil
        }
        guard let dright = drightOp else {
            return nil
        }

        if dleft == Number(0), dright == Number(0) {
            return Number(0)
        } else if dleft == Number(0) {
            return self.left * dright
        } else if dright == Number(0) {
            return self.right * dleft
        } else {
            return self.right * dleft + self.left * dright
        }
    }
}
