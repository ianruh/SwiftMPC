
//===================== Vector =================

// var str = ""

// // The flat vector
// let numericFlat = self.flat

// // Write the numeric flat vector placeholder
// str += "var flat: Vector = zeros(\(numericFlat.count))\n"

// // Get the pointer
// str += "flat.withUnsafeMutableBytes({ buffer in\n"

// // Write every one that needs updating
// for (index, element) in numericFlat.enumerated() {
//     // Only write it if the element is not equal to 0
//     if(numericFlat[index] != 0.0) {
//         str += "buffer[\(index)] = \(symbolicFlat[index])\n"
//     }
// }

// // Close the pointer closure
// str += "}\n"

// // Return the matrix with the flat vector
// return "Matrix(\(self.rows), \(self.cols), \(flat))"

public extension SymbolicVector {

    func swiftCode(using representations: Dictionary<Node, String>, onlyElements: Bool = false) throws -> String {
        var elementsStr = ""
        if self.elements.count > 0 {
            for i in 0..<self.elements.count-1 {
                var rep: String = try self.elements[i].swiftCode(using: representations)
                rep += ", "

                elementsStr += rep
            }
            elementsStr += "\(try self.elements.last!.swiftCode(using: representations))"
        }

        if(onlyElements) {
            return elementsStr
        } else {
            return "Vector([\(elementsStr)])"
        }
    }

    func swiftCode2(using representations: Dictionary<Node, String>, onlyElements: Bool = false) throws -> String {
        var str = ""

        // Write the numeric flat vector placeholder
        str += "var flat: Vector = zeros(\(self.elements.count))\n"

        // Get the pointer
        str += "flat.withUnsafeMutableBufferPointer({ buffer in\n"

        // Write every one that needs updating
        for i in 0..<self.elements.count {
            // Only write it if the element is not equal to 0
            if(self.elements[i] != Number(0.0)) {
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

    func swiftCode(using representations: Dictionary<Node, String>) throws -> String {
        var elementsStr = ""
        if self.vectors.count > 0 {
            for i in 0..<self.vectors.count-1 {
                var rep: String = try self.vectors[i].swiftCode(using: representations, onlyElements: true)
                rep += ",\n    "
                elementsStr += rep
            }
            elementsStr += "\(try self.vectors.last!.swiftCode(using: representations, onlyElements: true))"
        }

        return "Matrix(\(self.rows), \(self.cols), [\n    \(elementsStr)\n])"
    }

    func swiftCode2(using representations: Dictionary<Node, String>, onlyElements: Bool = false) throws -> String {
        var str = ""

        let symbolicFlat: [Node] = self.flat

        // Write the numeric flat vector placeholder
        str += "var flat: Vector = zeros(\(symbolicFlat.count))\n"

        // Get the pointer
        str += "flat.withUnsafeMutableBufferPointer({ buffer in\n"

        // Write every one that needs updating
        for i in 0..<symbolicFlat.count {
            // Only write it if the element is not equal to 0
            if(symbolicFlat[i] != Number(0.0)) {
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