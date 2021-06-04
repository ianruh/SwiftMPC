
public protocol SimulationObject {
    var boundingBox: BoundingBox { get }

    mutating func evolve(timeStep: Double)

}