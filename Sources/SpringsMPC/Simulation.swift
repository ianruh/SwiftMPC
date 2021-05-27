import LASwift

struct SpringsSimulator {
    var disturbanceMagnitude: Double = 1.0

    var positions: Vector
    var velocities: Vector

    var positionHistory: [Vector] = []
    var velocityHistory: [Vector] = []
    var timeHistory: [Double] = []

    init(initialPositions: Vector = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0], initialVelocities: Vector = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]) {
        self.positions = initialPositions
        self.velocities = initialVelocities

        self.positionHistory.append(initialPositions)
        self.velocityHistory.append(initialVelocities)
        self.timeHistory.append(0.0)
    }

    mutating func evolve(controls u: Vector, disturbance: Bool = true, _ dt: Double = 0.01) {
        var accels: Vector = zeros(6)
        let x = self.positions

        accels[0] = (0    - x[0]) + (x[1] - x[0]) + u[0]
        accels[1] = (x[0] - x[1]) + (x[2] - x[1]) - u[0]
        accels[2] = (x[1] - x[2]) + (x[3] - x[2]) + u[1]
        accels[3] = (x[2] - x[3]) + (x[4] - x[3]) + u[2]
        accels[4] = (x[3] - x[4]) + (x[5] - x[4]) - u[1]
        accels[5] = (x[4] - x[5]) + (0    - x[5]) - u[2]

        if(disturbance) {
            accels = accels + (rand(6) - 0.5).*self.disturbanceMagnitude
        }

        self.velocities = self.velocities + dt.*accels
        self.positions = self.positions + dt.*self.velocities

        // Save them into the history
        self.positionHistory.append(self.positions)
        self.velocityHistory.append(self.velocities)
        self.timeHistory.append(self.timeHistory.last! + dt)
    }
}