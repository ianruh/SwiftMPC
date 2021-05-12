//
// Created by Ian Ruh on 5/10/21.
//
import LASwift

public extension Node {

    func hessian() -> SymbolicMatrix? {
        let variables = self.orderedVariables

        var vectors: SymbolicMatrix = []

        // Set the ordering on the hessian matrix
        do {
            try vectors.setVariableOrder(self.orderedVariables)
        } catch {
            // Dis bad and should never happend
            print(error)
            preconditionFailure("This should never happen. File a bug: \(#file):\(#line)")
        }

        for variable1 in variables {

            var vectorElements: SymbolicVector = []
            guard let firstDerivative = differentiate(self, wrt: variable1)?.simplify() else {
                return nil
            }

            for variable2 in variables {

                guard let secondDerivative = differentiate(firstDerivative, wrt: variable2)?.simplify() else {
                    return nil
                }

                vectorElements.append(secondDerivative)
            }

            vectors.append(vectorElements)
        }

        return vectors
    }

}