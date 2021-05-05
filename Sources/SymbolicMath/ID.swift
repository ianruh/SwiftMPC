//
// Created by Ian Ruh on 8/29/20.
//

/// A unique(ish) identifier for each node
public struct Id {
    private static var next: UInt64 = 0
    private let value: UInt64

    public init() {
        self.value = Id.next
        Id.next += 1
    }

    public static func ==(_ lhs: Id, _ rhs: Id) -> Bool {
        return lhs.value == rhs.value
    }

    public static func !=(_ lhs: Id, _ rhs: Id) -> Bool {
        return !(lhs == rhs)
    }
}