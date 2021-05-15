
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

        var  gradVector: SymbolicVector = SymbolicVector(gradElements)

        // Set the ordering on the gradient vector. It inherits the ordering from
        // the original node
        gradVector.setVariableOrder(self.orderedVariables)

        return gradVector
    }

}