// Created 2020 github @ianruh

public extension SymbolicVector {
    /// Generate swift code for the symbolic vector.
    ///
    /// The form of the generated code is a `Vector` (a.k.a `Array<Double>`) literal.
    ///
    /// **For most purposes, the `swiftCode2` function should be used.**
    ///
    /// - Parameters:
    ///   - representations: The representations of each variable/parameter node. If other nodes are specified, they will be ignored.
    ///   - onlyElements: Whether only the vector element's representations should be returned (e.g. not the surrounding `[...]`)
    /// - Returns: The string representation of the code.
    /// - Throws: If the swift representation for an element cannot be generated.
    func swiftCode(using representations: [Node: String],
                   onlyElements: Bool = false) throws -> String
    {
        var elementsStr = ""
        if self.elements.count > 0 {
            for i in 0 ..< self.elements.count - 1 {
                var rep: String = try self.elements[i].swiftCode(using: representations)
                rep += ", "

                elementsStr += rep
            }
            elementsStr += "\(try self.elements.last!.swiftCode(using: representations))"
        }

        if onlyElements {
            return elementsStr
        } else {
            return "Vector([\(elementsStr)])"
        }
    }

    /// Generate swift code for the symbolic vector.
    ///
    /// Generates code of the form
    ///
    /// ```swift
    /// var flat: Vector = zeros(10)
    /// flat.withUnsafeMutableBufferPoint({ buffer in
    ///     buffer[0] = ...
    ///     buffer[1] = ...
    ///     ...
    /// })
    /// return flat
    /// ```
    ///
    /// The return statement is included in the returned string, so can only be used at the end of a function.
    ///
    /// - Parameters:
    ///   - representations: The swift code representations of variables & parameters. Representations for other nodes are ignored.
    /// - Returns: The string of teh swift code representation of the vector.
    /// - Throws: If the swift code for the vector cannot be generated.
    func swiftCode2(using representations: [Node: String]) throws -> String {
        var str = ""

        // Write the numeric flat vector placeholder
        str += "var flat: Vector = zeros(\(self.elements.count))\n"

        // Get the pointer
        str += "flat.withUnsafeMutableBufferPointer({ buffer in\n"

        // Write every one that needs updating
        for i in 0 ..< self.elements.count {
            // Only write it if the element is not equal to 0
            if self.elements[i] != Number(0.0) {
                str += "buffer[\(i)] = \(try self.elements[i].swiftCode(using: representations))\n"
            }
        }

        // Close the pointer closure
        str += "})\n"

        // Return the vector
        str += "return flat"

        return str
    }
}

//===================== Matrix =================

public extension SymbolicMatrix {
    /// Generate swift code for the matrix.
    ///
    /// Generates a LASwift.Matrix using an array literal.
    ///
    /// **The swiftCode2 functions should be used instead in genaeral.**
    ///
    /// - Parameter representations: The representations of the variables and parameters. All other nodes are ignored.
    /// - Returns: The string representation of the matrix.
    /// - Throws: If the swift code cannot be generated.
    func swiftCode(using representations: [Node: String]) throws -> String {
        var elementsStr = ""
        if self.vectors.count > 0 {
            for i in 0 ..< self.vectors.count - 1 {
                var rep: String = try self.vectors[i]
                    .swiftCode(using: representations, onlyElements: true)
                rep += ",\n    "
                elementsStr += rep
            }
            elementsStr +=
                "\(try self.vectors.last!.swiftCode(using: representations, onlyElements: true))"
        }

        return "Matrix(\(self.rows), \(self.cols), [\n    \(elementsStr)\n])"
    }

    /// Generate swift code representation of the matrix.
    ///
    /// Generates code of the form:
    ///
    /// ```swift
    /// var flat: Vector = zeros(10)
    /// flat.withUnsafeMutableBufferPoint({ buffer in
    ///     buffer[0] = ...
    ///     buffer[1] = ...
    ///     ...
    /// })
    /// return Matrix(rows, cols, flat)
    /// ```
    ///
    /// - Parameters:
    ///   - representations: The representations of the variables and parameters. All other nodes are ignored.
    /// - Returns: The string of the swift code representation of the matrix.
    /// - Throws: If the swift code representation cannot be generated.
    func swiftCode2(using representations: [Node: String]) throws -> String {
        var str = ""

        let symbolicFlat: [Node] = self.flat

        // Write the numeric flat vector placeholder
        str += "var flat: Vector = zeros(\(symbolicFlat.count))\n"

        // Get the pointer
        str += "flat.withUnsafeMutableBufferPointer({ buffer in\n"

        // Write every one that needs updating
        for i in 0 ..< symbolicFlat.count {
            // Only write it if the element is not equal to 0
            if symbolicFlat[i] != Number(0.0) {
                str += "buffer[\(i)] = \(try symbolicFlat[i].swiftCode(using: representations))\n"
            }
        }

        // Close the pointer closure
        str += "})\n"

        // Return the vector
        str += "return Matrix(\(self.rows), \(self.cols), flat)"

        return str
    }
}
