import LASwift

protocol ObjectiveWithInequality: Objective {
    var numConstraints: Int {get}
    func inequalityConstraintsValue(_ x: Vector) -> [Double]

    func inequalityConstraintsGradient(_ x: Vector) -> [Vector]

    func inequalityConstraintsHessian(_ x: Vector) -> [Matrix]
}