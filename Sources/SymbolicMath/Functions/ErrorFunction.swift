//import RealModule
//
//public class ErrorFunction: Node, Function {
//    public let identifier: String = "erf"
//    public let numArguments: Int = 1
//
//    // Store the parameters for the node
//    public var argument: Node
//
//    override public var description: String {
//        return "erf(\(self.argument))"
//    }
//
//    override public var latex: String {
//        return "\\textrm{erf}(\(self.argument.latex))"
//    }
//
//    override public var variables: Set<Variable> {
//        return self.argument.variables
//    }
//
//    override public var derivatives: Set<Derivative> {
//        return self.argument.derivatives
//    }
//
//    override public var typeIdentifier: String {
//        var hasher = Hasher()
//        self.hash(into: &hasher)
//        return "errorfunction\(hasher.finalize())"
//    }
//
//    required public init(_ params: [Node]) {
//        self.argument = params[0]
//    }
//
//    public convenience init(_ param: Node) {
//        self.init([param])
//    }
//
//    override required public convenience init() {
//        self.init([Node()])
//    }
//
//    override public func getSymbol<Engine:SymbolicMathEngine>(using type: Engine.Type) -> Engine.Symbol? {
//        guard let param = self.argument.getSymbol(using: type) else {return nil}
//        return Engine.erf(param)
//    }
//
//    @inlinable
//    override public func evaluate(withValues values: [Node: Double]) throws -> Double {
//        throw SymbolLabError.notApplicable(message: "erf not implemneted yet")
//    }
//
//    override internal func equals(_ otherNode: Node) -> Bool {
//        if let erf = otherNode as? ErrorFunction {
//            return self.argument.equals(erf.argument)
//        } else {
//            return false
//        }
//    }
//
//    override public func contains<T: Node>(nodeType: T.Type) -> [Id] {
//        var ids: [Id] = []
//        if(nodeType == ErrorFunction.self) {
//            ids.append(self.id)
//        }
//        ids.append(contentsOf: self.argument.contains(nodeType: nodeType))
//        return ids
//    }
//
//    @discardableResult override public func replace(_ targetNode: Node, with replacement: Node) -> Node {
//        if(targetNode == self) {
//            return replacement
//        } else {
//            return ErrorFunction(self.argument.replace(targetNode, with: replacement))
//        }
//    }
//
//    public override func simplify() -> Node {
//        return ErrorFunction(self.argument.simplify())
//    }
//
//    override public func hash(into hasher: inout Hasher) {
//        hasher.combine("erf")
//        hasher.combine(self.argument)
//    }
//}