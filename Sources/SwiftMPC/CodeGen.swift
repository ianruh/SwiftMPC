// Created 2020 github @ianruh

import LASwift
import SymbolicMath

public extension SymbolicObjective {
    func printSwiftCode(
        objectiveName: String,
        stateVectorName: String = "x",
        parameterRepresentations: [Parameter: String] = [:],
        matrixExtractors: [String: [[Variable]]] = [:],
        vectorExtractors: [String: [Variable]] = [:],
        variableExtractors: [String: Variable] = [:],
        toFile file: String? = nil
    ) throws {
        /// Utility function to generate a section label
        ///
        /// - Parameter str: The name of the label
        /// - Returns: A string header for the section
        func labelString(_ str: String) -> String {
            return "//=================== \(str) ==================="
        }

        // Check that every parameter has a representation in the parameterRepresentations dict
        for param in self.parameters {
            guard parameterRepresentations.keys.contains(param) else {
                throw SwiftMPCError.misc("No representation for the parameter \(param)")
            }
        }

        // Check that all of the variables to be extracted are in the model
        for variableMatrix in matrixExtractors.values {
            for variableVector in variableMatrix {
                for variable in variableVector {
                    guard self.orderedVariables.contains(variable) else {
                        throw SwiftMPCError
                            .misc("The variable \(variable) cannot be extracted because it is not in the model")
                    }
                }
            }
        }
        for variableVector in vectorExtractors.values {
            for variable in variableVector {
                guard self.orderedVariables.contains(variable) else {
                    throw SwiftMPCError
                        .misc("The variable \(variable) cannot be extracted because it is not in the model")
                }
            }
        }
        for variable in variableExtractors.values {
            guard self.orderedVariables.contains(variable) else {
                throw SwiftMPCError.misc("The variable \(variable) cannot be extracted because it is not in the model")
            }
        }

        // Merge the parameter representation dict with the generated variable representations dict
        var representation: [Node: String] = [:]
        representation
            .merge(parameterRepresentations, uniquingKeysWith: { current, _ in current }) // closure is useless
        for i in 0 ..< self.orderedVariables.count {
            representation[self.orderedVariables[i]] = "\(stateVectorName)[\(i)]"
        }

        // The base string. File contents are appended to this
        var str = ""

        //====== Compiler Directive ====
        str += "#if !NO_NUMERIC_OBJECTIVE"
        str += "\n"

        //====== Imports ====
        str += "import LASwift\n"
        str += "import RealModule\n"
        str += "import SwiftMPC\n"

        str += "\n\n"

        //====== Objective Declaration ====

        // Struct declearation
        str += "extension \(objectiveName): Objective {\n"

        //====== Stored Properties ====

        str += "\n"
        // Number of variables
        str += "var numVariables: Int { return \(self.numVariables) }\n"
        // Number of constraints
        str += "var numConstraints: Int { return \(self.numConstraints) }\n"

        //====== Extractors ====

        str += "\n"
        str += labelString("Extractors")
        str += "\n"

        // Matrix extractors
        for (matrixName, variableMatrix) in matrixExtractors {
            str += "\n"
            str += "@inlinable\n"
            str += "func extractMatrix_\(matrixName)(_ \(stateVectorName): Vector) -> Matrix {\n"
            str += "return "
            str += try SymbolicMatrix(variableMatrix).swiftCode(using: representation)
            str += "\n"
            str += "}"
            str += "\n"
        }

        // Vector extractors
        for (vectorName, variableVector) in vectorExtractors {
            str += "\n"
            str += "@inlinable\n"
            str += "func extractVector_\(vectorName)(_ \(stateVectorName): Vector) -> Vector {\n"
            str += "return "
            str += try SymbolicVector(variableVector).swiftCode(using: representation)
            str += "\n"
            str += "}"
            str += "\n"
        }

        // Variable extractors
        for (variableName, variable) in variableExtractors {
            str += "\n"
            str += "@inlinable\n"
            str += "func extractVariable_\(variableName)(_ \(stateVectorName): Vector) -> Double {\n"
            str += "return "
            str += try variable.swiftCode(using: representation)
            str += "\n"
            str += "}"
            str += "\n"
        }

        //====== Objective Properties ====

        str += "\n"

        // The Value
        str += labelString("Objective Value")
        str += "\n"
        str += "@inlinable\n"
        str += "func value(_ \(stateVectorName): Vector) -> Double {\n"
        str += "return "
        str += try self.objectiveNode.swiftCode(using: representation)
        str += "\n"
        str += "}"
        str += "\n\n"

        // The Gradient
        str += labelString("Gradient Value")
        str += "\n"
        str += "@inlinable\n"
        str += "func gradient(_ \(stateVectorName): Vector) -> Vector {\n"
        str += "return "
        str += try self.symbolicGradient.swiftCode(using: representation)
        str += "\n"
        str += "}"
        str += "\n\n"

        // The Hessian
        str += labelString("Hessian Value")
        str += "\n"
        str += "@inlinable\n"
        str += "func hessian(_ \(stateVectorName): Vector) -> Matrix {\n"
        str += "return "
        str += try self.symbolicHessian.swiftCode(using: representation)
        str += "\n"
        str += "}"
        str += "\n\n"

        //====== Equality Constraint Properties ====
        if let equalityMatrix = self.symbolicEqualityConstraintMatrix {
            if let equalityVector = self.symbolicEqualityConstraintVector {
                str += labelString("Equality Matrix Constraint")
                str += "\n"
                str += "var equalityConstraintMatrix: Matrix? {\n"
                str += "return "
                str += try equalityMatrix.swiftCode(using: representation)
                str += "\n"
                str += "}"
                str += "\n\n"

                str += labelString("Equality Vector Constraint")
                str += "\n"
                str += "var equalityConstraintVector: Vector? {\n"
                str += "return "
                str += try equalityVector.swiftCode(using: representation)
                str += "\n"
                str += "}"
                str += "\n\n"
            }
        }

        //====== Inequality Constraints ====

        // Constraints Value
        if let symbolicConstraintsValue = self.symbolicConstraintsValue {
            str += labelString("Inequality Constraints Value")
            str += "\n"
            str += "@inlinable\n"
            str += "func inequalityConstraintsValue(_ \(stateVectorName): Vector) -> Double {\n"
            str += "return "
            str += try symbolicConstraintsValue.swiftCode(using: representation)
            str += "\n"
            str += "}"
            str += "\n\n"
        }

        // Constraints Gradient
        if let symbolicConstraintsGradient = self.symbolicConstraintsGradient {
            str += labelString("Inequality Constraints Gradient")
            str += "\n"
            str += "@inlinable\n"
            str += "func inequalityConstraintsGradient(_ \(stateVectorName): Vector) -> Vector {\n"
            str += "return "
            str += try symbolicConstraintsGradient.swiftCode(using: representation)
            str += "}"
            str += "\n\n"
        }

        // Constraints Hessian
        if let symbolicConstraintsHessian = self.symbolicConstraintsHessian {
            str += labelString("Inequality Constraints Hessians")
            str += "\n"
            str += "@inlinable\n"
            str += "func inequalityConstraintsHessian(_ \(stateVectorName): Vector) -> Matrix {\n"
            str += "return "
            str += try symbolicConstraintsHessian.swiftCode(using: representation)
            str += "}"
            str += "\n\n"
        }

        // Close struct
        str += "}\n"

        //====== Compiler Directive Close ====
        str += "#endif"

        if let fileName = file {
            try str.write(toFile: fileName, atomically: true, encoding: String.Encoding.utf8)
        } else {
            print(str)
        }
    }

    func printSwiftCode2(
        objectiveName: String,
        stateVectorName: String = "x",
        parameterRepresentations: [Parameter: String] = [:],
        matrixExtractors: [String: [[Variable]]] = [:],
        vectorExtractors: [String: [Variable]] = [:],
        variableExtractors: [String: Variable] = [:],
        primalConstructor: Bool = false,
        toFile file: String? = nil
    ) throws {
        /// Utility function to generate a section label
        ///
        /// - Parameter str: The name of the label
        /// - Returns: A string header for the section
        func labelString(_ str: String) -> String {
            return "//=================== \(str) ==================="
        }

        // Check that every parameter has a representation in the parameterRepresentations dict
        for param in self.parameters {
            guard parameterRepresentations.keys.contains(param) else {
                throw SwiftMPCError.misc("No representation for the parameter \(param)")
            }
        }

        // Check that all of the variables to be extracted are in the model
        for variableMatrix in matrixExtractors.values {
            for variableVector in variableMatrix {
                for variable in variableVector {
                    guard self.orderedVariables.contains(variable) else {
                        throw SwiftMPCError
                            .misc("The variable \(variable) cannot be extracted because it is not in the model")
                    }
                }
            }
        }
        for variableVector in vectorExtractors.values {
            for variable in variableVector {
                guard self.orderedVariables.contains(variable) else {
                    throw SwiftMPCError
                        .misc("The variable \(variable) cannot be extracted because it is not in the model")
                }
            }
        }
        for variable in variableExtractors.values {
            guard self.orderedVariables.contains(variable) else {
                throw SwiftMPCError.misc("The variable \(variable) cannot be extracted because it is not in the model")
            }
        }

        // If we are making the primal constructor, then we need to makes sure every variables is
        // in one of the extractors
        if primalConstructor {
            for variable in self.orderedVariables {
                let matrixContains: Bool = matrixExtractors.values.reduce(false) { runningValue, matrix in
                    runningValue || matrix.reduce(false) { $0 || $1.contains(variable) }
                }
                let vectorContains: Bool = vectorExtractors.values.reduce(false) { $0 || $1.contains(variable) }
                let variableContains: Bool = variableExtractors.values.contains(variable)
                guard matrixContains || vectorContains || variableContains else {
                    throw SwiftMPCError
                        .misc(
                            "In order to construct the primalConstructor, every variable must be in an extractor. \(variable) was not found."
                        )
                }
            }
        }
        // Utility function for constructing the primal constructor
        // If it gets called, then we have already checked that every variable is represented,
        // so it is sae to assume it will always return a reference
        func primalConstructorGetVariableString(_ variable: Variable) -> String? {
            // Search in matrices
            for (matrixName, matrix) in matrixExtractors {
                for row in 0 ..< matrix.count {
                    for col in 0 ..< matrix[row].count {
                        if matrix[row][col] == variable {
                            return "\(matrixName)[\(row), \(col)]"
                        }
                    }
                }
            }
            // Search in vectors
            for (vectorName, vector) in vectorExtractors {
                for index in 0 ..< vector.count {
                    if vector[index] == variable {
                        return "\(vectorName)[\(index)]"
                    }
                }
            }
            // Search Variables
            for (variableName, variableEx) in variableExtractors {
                if variableEx == variable {
                    return "\(variableName)"
                }
            }
            // Fallback should never run
            return nil
        }

        // Merge the parameter representation dict with the generated variable representations dict
        var representation: [Node: String] = [:]
        representation
            .merge(parameterRepresentations, uniquingKeysWith: { current, _ in current }) // closure is useless
        for i in 0 ..< self.orderedVariables.count {
            representation[self.orderedVariables[i]] = "\(stateVectorName)[\(i)]"
        }

        // The base string. File contents are appended to this
        var str = ""

        //====== Compiler Directive ====
        str += "#if !NO_NUMERIC_OBJECTIVE"
        str += "\n"

        //====== Imports ====
        str += "import LASwift\n"
        str += "import RealModule\n"
        str += "import SwiftMPC\n"

        str += "\n\n"

        //====== Objective Declaration ====

        // Struct declearation
        str += "extension \(objectiveName): Objective {\n"

        //====== Stored Properties ====

        str += "\n"
        // Number of variables
        str += "var numVariables: Int { return \(self.numVariables) }\n"
        // Number of constraints
        str += "var numConstraints: Int { return \(self.numConstraints) }\n"

        //====== Extractors ====

        str += "\n"
        str += labelString("Extractors")
        str += "\n"

        // Matrix extractors
        for (matrixName, variableMatrix) in matrixExtractors {
            str += "\n"
            str += "@inlinable\n"
            str += "static func extractMatrix_\(matrixName)(_ \(stateVectorName): Vector) -> Matrix {\n"
            str += try SymbolicMatrix(variableMatrix).swiftCode2(using: representation)
            str += "\n"
            str += "}"
            str += "\n"
        }

        // Vector extractors
        for (vectorName, variableVector) in vectorExtractors {
            str += "\n"
            str += "@inlinable\n"
            str += "static func extractVector_\(vectorName)(_ \(stateVectorName): Vector) -> Vector {\n"
            str += try SymbolicVector(variableVector).swiftCode2(using: representation)
            str += "\n"
            str += "}"
            str += "\n"
        }

        // Variable extractors
        for (variableName, variable) in variableExtractors {
            str += "\n"
            str += "@inlinable\n"
            str += "static func extractVariable_\(variableName)(_ \(stateVectorName): Vector) -> Double {\n"
            str += "return "
            str += try variable.swiftCode(using: representation)
            str += "\n"
            str += "}"
            str += "\n"
        }

        //====== Primal vector constructor ======
        if primalConstructor {
            var parametersString = ""
            for matrixName in matrixExtractors.keys.sorted() {
                parametersString += "\(matrixName): Matrix, "
            }
            for vectorName in vectorExtractors.keys.sorted() {
                parametersString += "\(vectorName): Vector, "
            }
            // Variable extractors
            for variableName in variableExtractors.keys.sorted() {
                parametersString += "\(variableName): Double, "
            }

            // Remove the last space and comma
            parametersString = String(parametersString.dropLast())
            parametersString = String(parametersString.dropLast())

            str += labelString("Primal Constructor")
            str += "\n"
            str += "@inlinable\n"
            str += "static func constructPrimal(\(parametersString)) -> Vector {\n"
            // Write the numeric flat vector placeholder
            str += "var flat: Vector = zeros(\(self.orderedVariables.count))\n"

            // Get the pointer
            str += "flat.withUnsafeMutableBufferPointer({ buffer in\n"

            // Write every accessor
            for i in 0 ..< self.orderedVariables.count {
                str += "buffer[\(i)] = \(primalConstructorGetVariableString(self.orderedVariables[i])!)\n"
            }

            // Close the pointer closure
            str += "})\n"

            // Return the vector
            str += "return flat"
            str += "\n"
            str += "}"
            str += "\n"
        }

        //====== Objective Properties ====

        str += "\n"

        // The Value
        str += labelString("Objective Value")
        str += "\n"
        str += "@inlinable\n"
        str += "func value(_ \(stateVectorName): Vector) -> Double {\n"
        str += "return "
        str += try self.objectiveNode.swiftCode(using: representation)
        str += "\n"
        str += "}"
        str += "\n\n"

        // The Gradient
        str += labelString("Gradient Value")
        str += "\n"
        str += "@inlinable\n"
        str += "func gradient(_ \(stateVectorName): Vector) -> Vector {\n"
        str += try self.symbolicGradient.swiftCode2(using: representation)
        str += "\n"
        str += "}"
        str += "\n\n"

        // The Hessian
        str += labelString("Hessian Value")
        str += "\n"
        str += "@inlinable\n"
        str += "func hessian(_ \(stateVectorName): Vector) -> Matrix {\n"
        str += try self.symbolicHessian.swiftCode2(using: representation)
        str += "\n"
        str += "}"
        str += "\n\n"

        //====== Equality Constraint Properties ====
        if let equalityMatrix = self.symbolicEqualityConstraintMatrix {
            if let equalityVector = self.symbolicEqualityConstraintVector {
                str += labelString("Equality Matrix Constraint")
                str += "\n"
                str += "var equalityConstraintMatrix: Matrix? {\n"
                str += try equalityMatrix.swiftCode2(using: representation)
                str += "\n"
                str += "}"
                str += "\n\n"

                str += labelString("Equality Vector Constraint")
                str += "\n"
                str += "var equalityConstraintVector: Vector? {\n"
                str += try equalityVector.swiftCode2(using: representation)
                str += "\n"
                str += "}"
                str += "\n\n"
            }
        }

        //====== Inequality Constraints ====

        // Constraints Value
        if let symbolicConstraintsValue = self.symbolicConstraintsValue {
            str += labelString("Inequality Constraints Value")
            str += "\n"
            str += "@inlinable\n"
            str += "func inequalityConstraintsValue(_ \(stateVectorName): Vector) -> Double {\n"
            str += "return "
            str += try symbolicConstraintsValue.swiftCode(using: representation)
            str += "\n"
            str += "}"
            str += "\n\n"
        }

        // Constraints Gradient
        if let symbolicConstraintsGradient = self.symbolicConstraintsGradient {
            str += labelString("Inequality Constraints Gradient")
            str += "\n"
            str += "@inlinable\n"
            str += "func inequalityConstraintsGradient(_ \(stateVectorName): Vector) -> Vector {\n"
            str += try symbolicConstraintsGradient.swiftCode2(using: representation)
            str += "}"
            str += "\n\n"
        }

        // Constraints Hessian
        if let symbolicConstraintsHessian = self.symbolicConstraintsHessian {
            str += labelString("Inequality Constraints Hessians")
            str += "\n"
            str += "@inlinable\n"
            str += "func inequalityConstraintsHessian(_ \(stateVectorName): Vector) -> Matrix {\n"
            str += try symbolicConstraintsHessian.swiftCode2(using: representation)
            str += "}"
            str += "\n\n"
        }

        // Close struct
        str += "}\n"

        //====== Compiler Directive Close ====
        str += "#endif"

        if let fileName = file {
            try str.write(toFile: fileName, atomically: true, encoding: String.Encoding.utf8)
        } else {
            print(str)
        }
    }
}
