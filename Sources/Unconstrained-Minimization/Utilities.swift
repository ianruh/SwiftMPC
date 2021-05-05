//
// Created by Ian Ruh on 5/5/21.
//

import Numerics
import LASwift

precedencegroup ExponentiationPrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}

infix operator ** : ExponentiationPrecedence

func ** (_ base: Double, _ exp: Double) -> Double {
    return Double.pow(base, exp)
}

func norm(_ a: Vector) -> Double {
    return sumsq(a).squareRoot()
}