////
//// Created by Ian Ruh on 11/4/20.
////
//
//import LASwift
//
//public class Jacobian<Engine: SymbolicMathEngine>: CustomStringConvertible {
//    // Row major
//    public var elements: [[Node]]
//    public let system: System
//
//    public var description: String {
//        var str: String = ""
//        for row in self.elements {
//            str += "["
//            for el in row {
//                str += "\(el),  "
//            }
//            str += "]\n"
//        }
//        return str
//    }
//
//    public var m: Int {
//        return elements.count
//    }
//
//    public var n: Int {
//        guard elements.count > 0 else {
//            return 0
//        }
//        return elements[0].count
//    }
//
//    public init?(system: System) {
//        self.system = system
//        let variables = system.variableSequence
//        self.elements = []
//        for eq in system.equations {
//            // Make sure it is defined
//            guard let eqSymbol = eq.getSymbol(using: Engine.self) else {return nil}
//            // Make row
//            var row: [Node] = []
//            for variable in variables {
//                let node = variable
//                guard let nodeSymbol = node.getSymbol(using: Engine.self) else {return nil}
//                guard let derivative = Engine.partial(of: eqSymbol, withRespectTo: nodeSymbol) else {return nil}
////                print("Jacobian Derivative: \((derivative as! Node).description)")
//                guard let derivativeNode = Engine.constructNode(from: derivative) else {return nil}
//                row.append(derivativeNode)
//            }
//            // Append row
//            self.elements.append(row)
//        }
//    }
//
//    public func eval(_ values: [Node: Double]) throws -> Matrix {
//        let variables = self.system.variableSequence
//        // Check that all variables are represented
//        for v in variables {
//            if !values.keys.contains(v) {
//                throw SymbolLabError.noValue(forVariable: v.description)
//            }
//        }
//        // Evaluate each element
//        var evaledJacobian: [[Double]] = []
//        for row in 0..<self.m {
//            evaledJacobian.append([])
//            for col in 0..<self.n {
//                let nodep = self.elements[row][col]
//                let val = try nodep.evaluate(withValues: values)
//                evaledJacobian[row].append( val )
//            }
//        }
//        return Matrix(evaledJacobian)
//    }
//
//    /**
//    Assume the values are in order of sequence
//    */
//    public func eval(_ vec: Vector) throws -> Matrix {
//        var map = [Node: Double]()
//        for i in 0..<vec.count {
//            map[self.system.variableSequence[i]] = vec[i]
//        }
//        return try self.eval(map)
//    }
//}