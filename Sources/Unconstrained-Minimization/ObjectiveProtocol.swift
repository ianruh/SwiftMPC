//
// Created by Ian Ruh on 5/5/21.
//
import LASwift

protocol Objective {
    var numVariables: Int { get }

    func value(_ x: Vector) -> Double
    func gradient(_ x: Vector) -> Vector
    func hessian(_ x: Vector) -> Matrix
}