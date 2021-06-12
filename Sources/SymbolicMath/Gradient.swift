// Created 2020 github @ianruh

public extension Node {
    func gradient() -> SymbolicVector? {
        let variables = self.orderedVariables

        var gradElements: [Node] = []

        for variable in variables {
            guard let expression = differentiate(self, wrt: variable)?.simplify() else {
                return nil
            }
            gradElements.append(expression)
        }

        let gradVector = SymbolicVector(gradElements)

        // Set the ordering on the gradient vector. It inherits the ordering from
        // the original node
        try! gradVector.setVariableOrder(self.orderedVariables)

        return gradVector
    }
}
