import SymbolicMath
import LASwift

public extension SymbolicObjective {


    // /// Number of variables taken by the objective
    // var numVariables: Int { get }

    // /// Number of inequality constraints
    // var numConstraints: Int { get }

    // //==================== Objective =================

    // /// The value of the objective at a given point
    // ///
    // /// - Parameter x: The point to evaluate the objective at
    // /// - Returns: The value of teh objective
    // func value(_ x: Vector) -> Double

    // /// The value of the gradient at a given point
    // ///
    // /// - Parameter x: The point to evaulate the gradient at
    // /// - Returns: The value of teh gradient
    // func gradient(_ x: Vector) -> Vector

    // /// The value of the Hessian at a given point.
    // ///
    // /// - Parameter x: The point to evaluate the Hessian at.
    // /// - Returns: The value of the Hessian.
    // func hessian(_ x: Vector) -> Matrix

    // //================= Equality ================

    // var equalityConstraintMatrix: Matrix? { get }

    // var equalityConstraintVector: Vector? { get }

    // //=========== Inequality Constraints ============

    // func inequalityConstraintsValue(_ x: Vector) -> [Double]

    // func inequalityConstraintsGradient(_ x: Vector) -> [Vector]

    // func inequalityConstraintsHessian(_ x: Vector) -> [Matrix]

    func printSwiftCode(
            objectiveName: String,
            stateVectorName: String = "x", 
            toFile file: String? = nil) throws {
        func labelString(_ str: String) -> String {
            return "//=================== \(str) ==================="
        }

        var representation: Dictionary<Node, String> = [:]
        for i in 0..<self.orderedVariables.count {
            representation[self.orderedVariables[i]] = "\(stateVectorName)[\(i)]"
        }

        var str = ""

        //====== Imports ====
        str += "import LASwift\n"
        str += "import Numerics\n"
        str += "import Minimization\n"

        str += "\n\n"

        //====== Objective Declaration ====

        // Struct declearation
        str += "struct \(objectiveName) {\n"

        //====== Stored Properties ====

        str += "\n"
        // Number of variables
        str += "let numVariables: Int = \(self.numVariables)\n"
        // Number of constraints
        str += "let numConstraints: Int = \(self.numConstraints)\n"

        //====== Objective Properties ====

        str += "\n"

        // The Value
        str += labelString("Objective Value")
        str += "\n"
        str += "func value(_ \(stateVectorName): Vector) -> Double {\n"
        str += "return "
        str += try self.objectiveNode.swiftCode(using: representation)
        str += "\n"
        str += "}"
        str += "\n\n"

        // The Gradient
        str += labelString("Gradient Value")
        str += "\n"
        str += "func gradient(_ \(stateVectorName): Vector) -> Vector {\n"
        str += "return "
        str += try self.symbolicGradient.swiftCode(using: representation)
        str += "\n"
        str += "}"
        str += "\n\n"

        // The Hessian
        str += labelString("Hessian Value")
        str += "\n"
        str += "func hessian(_ \(stateVectorName): Vector) -> Matrix {\n"
        str += "return "
        str += try self.symbolicHessian.swiftCode(using: representation)
        str += "\n"
        str += "}"
        str += "\n\n"

        //====== Equality Constraint Properties ====
        if let equalityMatrix = self.equalityConstraintMatrix {
            if let equalityVector = self.equalityConstraintVector {
                str += labelString("Equality Matrix Constraint")
                str += "\n"
                str += "let equalityConstraintMatrix: Matrix? = "
                str += equalityMatrix.swiftCode()
                str += "\n\n"

                str += labelString("Equality Vector Constraint")
                str += "\n"
                str += "let equalityConstraintVector: Vector? = "
                str += equalityVector.swiftCode()
                str += "\n\n"
            }
        }

        //====== Inequality Constraints ====

        // Constraints Value
        if let symbolicConstraints = self.symbolicConstraints {
            str += labelString("Inequality Constraints Values")
            str += "\n"
            str += "func inequalityConstraintsValue(_ \(stateVectorName): Vector) -> [Double] {\n"
            str += "return "
            str += try symbolicConstraints.swiftCode(using: representation)
            str += "\n"
            str += "}"
            str += "\n\n"
        }

        // Constraints Gradient
        if let symbolicConstraintsGradient = self.symbolicConstraintsGradient {
            str += labelString("Inequality Constraints Gradients")
            str += "\n"
            str += "func inequalityConstraintsGradient(_ \(stateVectorName): Vector) -> [Vector] {\n"
            str += "return [\n"
            for vector in symbolicConstraintsGradient {
                str += try vector.swiftCode(using: representation)
                str += ",\n"
            }
            str += "]\n"
            str += "}"
            str += "\n\n"
        }

        // Constraints Hessian
        if let symbolicConstraintsHessian = self.symbolicConstraintsHessian {
            str += labelString("Inequality Constraints Hessians")
            str += "\n"
            str += "func inequalityConstraintsHessian(_ \(stateVectorName): Vector) -> [Matrix] {\n"
            str += "return [\n"
            for matrix in symbolicConstraintsHessian {
                str += try matrix.swiftCode(using: representation)
                str += ",\n"
            }
            str += "]\n"
            str += "}"
            str += "\n\n"
        }

        // Close struct
        str += "}\n"

        if let fileName = file {
            try str.write(toFile: fileName, atomically: true, encoding: String.Encoding.utf8)
        } else {
            print(str)
        }
    }

}

public extension Matrix {
    func swiftCode() -> String {
        return "Matrix(\(self.rows), \(self.cols), \(self.flat.swiftCode()))"
    }
}

public extension Vector {
    func swiftCode() -> String {
        var str = ""
        str += "Vector(["
        if(self.count > 1) {
            for i in 0..<self.count-1 {
                str += "\(self[i]), "
            }
            str += "\(self.last!)"
        }
        str += "])"

        return str
    }
}