// Created 2020 github @ianruh

import Foundation
import LASwift
import RealModule

extension String {

    /// Returns true is the string is an integer.
    var isInteger: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }

    /// Returns true if the string is a double
    var isDouble: Bool {
        guard self.count > 0 else { return false }
        let parts = self.split(separator: ".")
        if parts.count == 2 {
            return String(parts[0]).isInteger && String(parts[1]).isInteger
        } else if parts.count == 1 {
            return String(parts[0]).isInteger
        }
        return false
    }

    /// Returns true if it is an integer or a double.
    var isNumber: Bool {
        return self.isInteger || self.isDouble
    }

    /// Returns true if it is only letters
    var isAlphabetic: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = [
            "A",
            "B",
            "C",
            "D",
            "E",
            "F",
            "G",
            "H",
            "I",
            "J",
            "K",
            "L",
            "M",
            "N",
            "O",
            "P",
            "Q",
            "R",
            "S",
            "T",
            "U",
            "V",
            "W",
            "X",
            "Y",
            "Z",
            "a",
            "b",
            "c",
            "d",
            "e",
            "f",
            "g",
            "h",
            "i",
            "j",
            "k",
            "l",
            "m",
            "n",
            "o",
            "p",
            "q",
            "r",
            "s",
            "t",
            "u",
            "v",
            "w",
            "x",
            "y",
            "z",
        ]
        return Set(self).isSubset(of: nums)
    }

    /// Removes all whitespace (space, tab, new line) from the string.
    public func cleanWhiteSpace() -> String {
        var str = ""
        let whitespace: Set<Character> = [" ", "\t", "\n"]
        for c in self {
            if !whitespace.contains(c) {
                str += String(c)
            }
        }
        return str
    }

    /// Does the string have a valid set of opening and closing parantheses.
    var hasValidParetheses: Bool {
        var level = 0
        for c in self {
            if c == "(" {
                level += 1
            } else if c == ")" {
                level -= 1
            }
            // handle ))((
            if level < 0 {
                return false
            }
        }
        return level == 0
    }
}

public extension Int {
    static func random(withDigits digits: Int) -> Int {
        var str = ""
        for _ in 0 ..< digits {
            str += String(Int.random(in: 0 ..< 9))
        }
        return Int(str)!
    }

    static func random(withMaxDigits maxDigits: Int) -> Int {
        return Int.random(withDigits: Int.random(in: 1 ... maxDigits))
    }
}

public extension Array where Element: CustomStringConvertible {
    func join(separator: String) -> String {
        var str = ""
        if self.count > 0 {
            for e in self.dropLast() {
                str += "\(e)\(separator)"
            }
            str += "\(self.last!)"
        }
        return str
    }
}

public extension Set {
    static func + (lhs: Set, rhs: Set) -> Set {
        return lhs.union(rhs)
    }
}

public extension Double {
    /// Get a six decimal accuracy number
    var sixAc: String {
        return String(format: "%0.6f", self)
    }

    /// Get whole value of double
    var whole: Int {
        var d = self
        d.round(.towardZero)
        return Int(d)
    }

    var symbol: Number {
        return Number(self)
    }
}

public extension Collection where Element: Collection {
    var pprint: String {
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
    vec.forEach { sum += .pow($0, 2) }
    return .root(sum, val)
}

public func * (_ lhs: Double, _ rhs: Vector) -> Vector {
    var vec: Vector = []
    for i in 0 ..< rhs.count {
        vec.append(lhs * rhs[i])
    }
    return vec
}

public func + (_ lhs: Double, _ rhs: Vector) -> Vector {
    var vec: Vector = []
    for i in 0 ..< rhs.count {
        vec.append(lhs + rhs[i])
    }
    return vec
}

public func * (_ lhs: String, _ rhs: Int) -> String {
    var str = ""
    for _ in 0 ..< rhs {
        str += lhs
    }
    return str
}

public func printDebug(_ msg: Any, file: StaticString = #file, line: UInt = #line) {
    print("Got to \(file):\(line) \(msg)")
}

// https://talk.objc.io/episodes/S01E90-concurrent-map
extension Array {
    func parallelMap<B>(_ transform: @escaping (Element) -> B) -> [B] {
        #if !NO_PARALLEL
        var result = [B?](repeating: nil, count: count)
        let q = DispatchQueue(label: "sync queue")
        DispatchQueue.concurrentPerform(iterations: count) { idx in
            let element = self[idx]
            let transformed = transform(element)
            q.sync {
                result[idx] = transformed
            }
        }
        return result.map { $0! }
        #else
        return self.map(transform)
        #endif
    }
}

extension Int {
    func factorial() -> Int {
        guard self >= 0 else {
            preconditionFailure("Factorial must be of a non-negative integer.")
        }
        // 1 case
        guard self != 0 else {
            return 1
        }

        var current: Int = 1
        for i in 1 ... self {
            current *= i
        }
        return current
    }
}
