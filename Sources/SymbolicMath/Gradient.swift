//
//public class Gradient: System {
//
//    public init(_ function: Node) {
//        let variables = function.variables.sorted()
//
//        var gradElements: [Node] = []
//
//        // Implicitly, every thing is assumed equal to 0, so if we run solve on the gradient, we'll
//        // get when it is equal to 0.
//        for variable in variables {
//            gradElements.append(Partial(of: function, wrt: variable))
//        }
//
//        super.init(gradElements)
//    }
//
//    public required init(arrayLiteral: ArrayLiteralElement...) {
//        super.init(arrayLiteral)
//    }
//}