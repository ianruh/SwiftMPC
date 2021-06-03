import Numerics

public struct Vec2 {
    public var x: Double
    public var y: Double

    public var norm: Double {
        return Double.sqrt(x*x + y*y)
    }

    public init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }
}

public func *(_ lhs: Double, _ rhs: Vec2) -> Vec2 {
    return Vec2(lhs*rhs.x, lhs*rhs.y)
}
public func *(_ lhs: Vec2, _ rhs: Double) -> Vec2 {
    return Vec2(lhs.x*rhs, lhs.y*rhs)
}

public func +(_ lhs: Vec2, _ rhs: Vec2) -> Vec2 {
    return Vec2(lhs.x+rhs.x, lhs.y+rhs.y)
}
public func +(_ lhs: Vec2, _ rhs: Double) -> Vec2 {
    return Vec2(lhs.x + rhs, lhs.y + rhs)
}
public func +(_ lhs: Double, _ rhs: Vec2) -> Vec2 {
    return Vec2(lhs + rhs.x, lhs + rhs.y)
}