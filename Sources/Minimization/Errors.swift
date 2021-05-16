//
// Created by Ian Ruh on 5/9/21.
//

enum MinimizationError: Error {
    case wrongNumberOfVariables(_ msg: String)
    case misc(_ msg: String)
}