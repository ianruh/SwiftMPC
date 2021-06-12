
public struct BoundingBox {
    public var minX: Double
    public var maxX: Double
    public var minY: Double
    public var maxY: Double

    public var width: Double {
        return self.maxX - self.minX
    }

    public var height: Double {
        return self.maxY - self.minY
    }

    public var center: Vec2 {
        return Vec2((self.minX + self.maxX)/2, (self.minY + self.maxY)/2)
    }

    public init(minX: Double, maxX: Double, minY: Double, maxY: Double) {
        self.minX = minX
        self.maxX = maxX
        self.minY = minY
        self.maxY = maxY
    }

    public init(center: Vec2, width: Double, height: Double) {
        self.minX = center.x - width/2
        self.maxX = center.x + width/2
        self.minY = center.y - height/2
        self.maxY = center.y + height/2
    }
    
    public func isInBox(_ pt: Vec2) -> Bool {
        return pt.x > self.minX && pt.x < self.maxX && pt.y > self.minY && pt.y < self.maxY
    }

    public func relativePosition(of pt: Vec2, along axis: Axis) -> BoundingBox.RelativePosition {
        if(axis == .X) {
            if(pt.x > self.maxX) {
                return RelativePosition.above
            } else if(pt.x < self.minX) {
                return RelativePosition.below
            } else {
                return RelativePosition.inside
            }
        } else {
            if(pt.y > self.maxY) {
                return RelativePosition.above
            } else if(pt.y < self.minY) {
                return RelativePosition.below
            } else {
                return RelativePosition.inside
            }
        }
    }

    public func intersectsLine(x: Double) -> Bool {
        return x > self.minX && x < self.maxX
    }

    public func intersectsLine(y: Double) -> Bool {
        return y > self.minY && y < self.maxY
    }

    public enum RelativePosition {
        case above, inside, below
    }
}
