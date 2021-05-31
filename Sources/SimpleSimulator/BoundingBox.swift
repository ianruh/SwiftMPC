
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
}