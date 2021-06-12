// Created 2020 github @ianruh

public class SimpleSimulator {
    var objects: [SimulationObject] = []
    var environmentBoundary: BoundingBox

    public func addObject(_ obj: SimulationObject) {
        self.objects.append(obj)
    }

    public func getObjects() -> [SimulationObject] {
        return self.objects
    }

    public func getObjectsIntersecting(x: Double) -> [SimulationObject] {
        var objs: [SimulationObject] = []
        for obj in self.objects {
            if obj.boundingBox.intersectsLine(x: x) {
                objs.append(obj)
            }
        }
        return objs
    }

    public func getObjectsIntersecting(y: Double) -> [SimulationObject] {
        var objs: [SimulationObject] = []
        for obj in self.objects {
            if obj.boundingBox.intersectsLine(y: y) {
                objs.append(obj)
            }
        }
        return objs
    }

    public func evolve(timeStep: Double) {
        for i in 0 ..< self.objects.count {
            self.objects[i].evolve(timeStep: timeStep)
        }
    }

    public func isInObject(_ pt: Vec2) -> Bool {
        for obj in self.objects {
            if obj.boundingBox.isInBox(pt) {
                return true
            }
        }
        return false
    }

    public func getFreeSpace(atPositions positions: [Vec2], along axis: Axis) -> [(min: Double?, max: Double?)] {
        return positions.map { self.getFreeSpace(atPosition: $0, along: axis) }
    }

    public func getFreeSpace(atPosition position: Vec2, along axis: Axis) -> (min: Double?, max: Double?) {
        if axis == .X {
            let intersectingObjects = self.getObjectsIntersecting(x: position.x)
            var minX = self.environmentBoundary.minX
            var maxX = self.environmentBoundary.maxX

            for obj in intersectingObjects {
                let relativePosition = obj.boundingBox.relativePosition(of: position, along: axis)
                if relativePosition == .inside {
                    return (min: nil, max: nil)
                } else if relativePosition == .above {
                    maxX = obj.boundingBox.minX < maxX ? obj.boundingBox.minX : maxX
                } else if relativePosition == .below {
                    minX = obj.boundingBox.maxX > minX ? obj.boundingBox.maxX : minX
                }
            }

            return (min: minX, max: maxX)
        } else {
            let intersectingObjects = self.getObjectsIntersecting(y: position.y)
            var minY = self.environmentBoundary.minY
            var maxY = self.environmentBoundary.maxY

            for obj in intersectingObjects {
                let relativePosition = obj.boundingBox.relativePosition(of: position, along: axis)
                if relativePosition == .inside {
                    return (min: 0.0, max: 0.0)
                } else if relativePosition == .above {
                    maxY = obj.boundingBox.minY < maxY ? obj.boundingBox.minY : maxY
                } else if relativePosition == .below {
                    minY = obj.boundingBox.maxY > minY ? obj.boundingBox.maxY : minY
                }
            }

            return (min: minY, max: maxY)
        }
    }

    public init(environmentBoundary: BoundingBox = BoundingBox(center: Vec2(0.0, 0.0), width: 1000.0, height: 1000.0)) {
        self.environmentBoundary = environmentBoundary
    }
}
