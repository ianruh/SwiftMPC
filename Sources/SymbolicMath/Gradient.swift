
public extension Node {

    func gradient() -> SymbolicVector? {
        let variables = self.orderedVariables

        var gradElements: SymbolicVector = []

        // Set the ordering on the gradient vector
        do {
            try gradElements.setVariableOrder(self.orderedVariables)
        } catch {
            // Dis bad and should never happen
            print(error)
            preconditionFailure("This should never happen. File a bug: \(#file):\(#line)")
        }

        for variable in variables {
            guard let expression = differentiate(self, wrt: variable)?.simplify() else {
                return nil
            }
            gradElements.append(expression)
        }

        return gradElements
    }

}