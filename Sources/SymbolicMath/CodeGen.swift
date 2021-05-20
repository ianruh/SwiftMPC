
//===================== Vector =================

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

}