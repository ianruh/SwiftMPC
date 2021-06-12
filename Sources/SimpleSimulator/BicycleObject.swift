// Created 2020 github @ianruh

public struct BicycleObject: SimulationObject {
    // State
    var frontWheelPosition: Vec2
    var velocity: Double
    var angle: Double
    var wheelBase: Double

    // Control
    public var acceleration: Double
    public var steeringAngle: Double

    public init(
        position: Vec2 = Vec2(0.0, 0.0),
        velocity: Double = 0.0,
        angle: Double = 0.0,
        wheelBase: Double = 2.0,
        acceleration: Double = 0.0,
        steeringAngle: Double = 0.0
    ) {
        self.frontWheelPosition = position
        self.velocity = velocity
        self.angle = angle
        self.wheelBase = wheelBase

        self.acceleration = acceleration
        self.steeringAngle = steeringAngle
    }

    public var boundingBox: BoundingBox {
        var minX = self.frontWheelPosition.x - self.wheelBase * Double.cos(self.angle)
        var maxX = self.frontWheelPosition.x
        if minX > maxX {
            let temp = minX
            minX = maxX
            maxX = temp
        }

        var minY = self.frontWheelPosition.y - self.wheelBase * Double.sin(self.angle)
        var maxY = self.frontWheelPosition.y
        if minY > maxY {
            let temp = minY
            minY = maxY
            maxY = temp
        }

        return BoundingBox(minX: minX, maxX: maxX, minY: minY, maxY: maxY)
    }

    public mutating func evolve(timeStep: Double) {
        self.frontWheelPosition = self.frontWheelPosition + timeStep * Vec2(
            self.velocity * Double.cos(self.angle + self.steeringAngle),
            self.velocity * Double.sin(self.angle + self.steeringAngle)
        )
        self.angle = self.angle + timeStep * self.velocity / self.wheelBase * Double.sin(self.steeringAngle)
        self.velocity = self.velocity + timeStep * self.acceleration
    }
}
