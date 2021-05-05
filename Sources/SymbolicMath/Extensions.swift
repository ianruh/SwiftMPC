//
//  File.swift
//  
//
//  Created by Ian Ruh on 5/16/20.
//
// Extensions of types not defined in this repo

import LASwift
import RealModule

extension String {
    var isInteger: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
    
    var isDouble: Bool {
        guard self.count > 0 else { return false }
        let parts = self.split(separator: ".")
        if(parts.count == 2) {
            return String(parts[0]).isInteger && String(parts[1]).isInteger
        } else if(parts.count == 1) {
            return String(parts[0]).isInteger
        }
        return false
    }
    
    var isNumber: Bool {
        return self.isInteger || self.isDouble
    }

    var isAlphabetic: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
        return Set(self).isSubset(of: nums)
    }
    
    public func cleanWhiteSpace() -> String {
        var str = ""
        let whitespace: Set<Character> = [" ", "\t", "\n"]
        for c in self {
            if(!whitespace.contains(c)) {
                str += String(c)
            }
        }
        return str
    }
    
    var hasValidParetheses: Bool {
        var level = 0
        for c in self {
            if(c == "(") {
                level += 1
            } else if(c == ")") {
                level -= 1
            }
            // handle ))((
            if(level < 0) {
                return false
            }
        }
        return level == 0
    }
}


extension Int {
    public static func random(withDigits digits: Int) -> Int {
        var str = ""
        for _ in 0..<digits {
            str += String(Int.random(in: 0..<9))
        }
        return Int(str)!
    }
    
    public static func random(withMaxDigits maxDigits: Int) -> Int {
        return Int.random(withDigits: Int.random(in: 1...maxDigits))
    }
    
}

extension Array where Element: CustomStringConvertible {
    public func join(separator: String) -> String {
        var str = ""
        if(self.count > 0) {
            for e in self.dropLast() {
                str += "\(e)\(separator)"
            }
            str += "\(self.last!)"
        }
        return str
    }
}

extension Set {
    public static func +(lhs: Set, rhs: Set) -> Set {
        return lhs.union(rhs)
    }
}

extension Double {
    /// Get a six decimal accuracy number
    public var sixAc: String {
        return String(format: "%0.6f", self)
    }

    /// Get whole value of double
    public var whole: Int {
        var d = self
        d.round(.towardZero)
        return Int(d)
    }

    /// Get Integer of fractional value
    public var frac: Int {
        let str = String(self)
        var ind = str.firstIndex(of: ".")!
        str.formIndex(after: &ind)
        return Int(str.substring(from: ind))!
    }
}

extension Collection where Element: Collection {
    public var pprint: String {
        var str: String = ""
        for row in self {
            str += "["
            for el in row {
                str += "\(el),  "
            }
            str += "]\n"
        }
        return str
    }
}

/**
Not quite an extension, but close enough
*/
public func norm(_ vec: Vector, _ val: Int = 2) -> Double {
    var sum = 0.0
    vec.forEach({sum += .pow($0, 2)})
    return .root(sum, val)
}

public func * (_ lhs: Double, _ rhs: Vector) -> Vector {
    var vec: Vector = []
    for i in 0..<rhs.count {
        vec.append(lhs*rhs[i])
    }
    return vec
}

public func + (_ lhs: Double, _ rhs: Vector) -> Vector {
    var vec: Vector = []
    for i in 0..<rhs.count {
        vec.append(lhs+rhs[i])
    }
    return vec
}
