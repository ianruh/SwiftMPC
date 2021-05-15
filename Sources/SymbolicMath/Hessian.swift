//
// Created by Ian Ruh on 5/10/21.
//
import LASwift

public extension Node {

    func hessian() -> SymbolicMatrix? {
        let variables = self.orderedVariables

        var vectors: [SymbolicVector] = []

        for variable1 in variables {

            var vectorElements: [Node] = []
            guard let firstDerivative = differentiate(self, wrt: variable1)?.simplify() else {
                return nil
            }

            for variable2 in variables {

                guard let secondDerivative = differentiate(firstDerivative, wrt: variable2)?.simplify() else {
                    return nil
                }

                vectorElements.append(secondDerivative)
            }

            vectors.append(SymbolicVector(vectorElements))
        }

        var hessianMatrix = SymbolicMatrix(vectors)

        // Set the ordering on the hessian matrix. It Inherits the ordering
        // from the original node.
        hessianMatrix.setVariableOrder(self.orderedVariables)

        return hessianMatrix
    }

}