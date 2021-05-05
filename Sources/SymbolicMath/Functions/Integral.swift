//import RealModule
//
//public class Integral: Node, Function {
//    public let identifier: String = "int"
//    public let numArguments: Int = 4
//
//    // Store the parameters for the node
//    private var integrand: Node
//    private var withRespectTo: Node
//    private var lowerBound: Node
//    private var upperBound: Node
//
//    override public var description: String {
//        return "int(\(self.integrand),\(self.withRespectTo),\(self.lowerBound),\(self.upperBound))"
//    }
//
//    override public var latex: String {
//        let bottomStr = "\(self.lowerBound.latex)"
//        let topStr = "\(self.upperBound.latex)"
//        let integrandStr = "\(self.integrand.latex)"
//        var withRespectToStr = "\(self.withRespectTo.latex)"
//        if(!self.withRespectTo.isBasic) {
//            withRespectToStr = "(\(withRespectToStr))"
//        }
//
//        return "\\int_{\(bottomStr)}^{\(topStr)} \(integrandStr) d\(withRespectToStr)"
//    }
//
//    override public var variables: Set<Variable> {
//        return self.integrand.variables + self.withRespectTo.variables + self.lowerBound.variables + self.upperBound.variables
//    }
//
//    override public var derivatives: Set<Derivative> {
//        return self.integrand.derivatives +
//            self.withRespectTo.derivatives +
//            self.lowerBound.derivatives +
//            self.upperBound.derivatives
//    }
//
//    override public var typeIdentifier: String {
//        var hasher = Hasher()
//        self.hash(into: &hasher)
//        return "integral\(hasher.finalize())"
//    }
//
//    required public init(_ params: [Node]) {
//        self.integrand = params[0]
//        self.withRespectTo = params[1]
//        self.lowerBound = params[2]
//        self.upperBound = params[3]
//    }
//
//    override required public convenience init() {
//        self.init([Node(), Node(), Node(), Node()])
//    }
//
//    override public func getSymbol<Engine:SymbolicMathEngine>(using type: Engine.Type) -> Engine.Symbol? {
//        // TODO: Symbolic integration
//        return nil
//    }
//
//    @inlinable
//    override public func evaluate(withValues values: [Node: Double]) throws -> Double {
//        // TODO: Numerical integration
//        throw SymbolLabError.notApplicable(message: "Can't evaluate integrals")
//    }
//
//    override internal func equals(_ otherNode: Node) -> Bool {
//        if let int = otherNode as? Integral {
//            return self.integrand.equals(int.integrand) &&
//                self.withRespectTo.equals(int.withRespectTo) &&
//                self.lowerBound.equals(int.lowerBound) &&
//                self.upperBound.equals(int.upperBound)
//        } else {
//            return false
//        }
//    }
//
//    override public func contains<T: Node>(nodeType: T.Type) -> [Id] {
//        var ids: [Id] = []
//        if(nodeType == Integral.self) {
//            ids.append(self.id)
//        }
//        ids.append(contentsOf: self.integrand.contains(nodeType: nodeType))
//        ids.append(contentsOf: self.withRespectTo.contains(nodeType: nodeType))
//        ids.append(contentsOf: self.lowerBound.contains(nodeType: nodeType))
//        ids.append(contentsOf: self.upperBound.contains(nodeType: nodeType))
//        return ids
//    }
//
//    @discardableResult override public func replace(_ targetNode: Node, with replacement: Node) -> Node {
//        if(targetNode == self) {
//            return replacement
//        } else {
//            return Integral([self.integrand.replace(targetNode, with: replacement), self.withRespectTo.replace(targetNode, with: replacement), self.upperBound.replace(targetNode, with: replacement), self.lowerBound.replace(targetNode, with: replacement)])
//        }
//    }
//
//    public override func simplify() -> Node {
//        return Integral([self.integrand.simplify(), self.withRespectTo.simplify(), self.upperBound.simplify(), self.lowerBound.simplify()])
//    }
//
//    override public func hash(into hasher: inout Hasher) {
//        hasher.combine("integral")
//        hasher.combine(self.integrand)
//        hasher.combine(self.withRespectTo)
//        hasher.combine(self.upperBound)
//        hasher.combine(self.lowerBound)
//    }
//}