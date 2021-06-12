// Created 2020 github @ianruh

public struct RectangleObject: SimulationObject {
    var position: Vec2 // Center
    var velocity: Vec2
    var acceleration: Vec2

    let width: Double = 1.0
    let height: Double = 2.0

    public var boundingBox: BoundingBox {
        return BoundingBox(center: self.position, width: self.width, height: self.height)
    }

    public mutating func evolve(timeStep: Double) {
        self.velocity = self.velocity + timeStep * self.acceleration
        self.position = self.position + timeStep * self.velocity
    }
}
