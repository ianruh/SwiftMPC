// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftMPC",
    products: [
        .library(name: "SwiftMPC", targets: ["SwiftMPC", "SymbolicMath"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics.git", from: "0.0.8"),
        .package(url: "https://github.com/ianruh/LASwift.git", .branch("linux")),
        .package(url: "https://github.com/apple/swift-collections.git", from: "0.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftMPC",
            dependencies: [
                .product(name: "RealModule", package: "swift-numerics"),
                "LASwift",
                "SymbolicMath",
                .product(name: "Collections", package: "swift-collections")
            ]),
        .target(
            name: "SymbolicMath",
            dependencies: [
                .product(name: "RealModule", package: "swift-numerics"),
                "LASwift",
                .product(name: "Collections", package: "swift-collections")
            ]),
        .target(
            name: "SimpleSimulator",
            dependencies: [
                .product(name: "RealModule", package: "swift-numerics"),
                "LASwift"
            ]),
        .target(
            name: "StraightLineMPC",
            dependencies: [
                .product(name: "RealModule", package: "swift-numerics"),
                "LASwift",
                "SymbolicMath",
                .product(name: "Collections", package: "swift-collections"),
                "SwiftMPC"
            ]),
        .target(
            name: "SpringsMPC",
            dependencies: [
                .product(name: "RealModule", package: "swift-numerics"),
                "LASwift",
                "SymbolicMath",
                .product(name: "Collections", package: "swift-collections"),
                "SwiftMPC"
            ]),
        .testTarget(
            name: "SymbolicMathTests",
            dependencies: [
                "SymbolicMath", 
                "LASwift",
                .product(name: "Collections", package: "swift-collections")
            ]),
        .testTarget(
            name: "SwiftMPCTests",
            dependencies: [
                "SwiftMPC",
                "LASwift",
                "SymbolicMath",
                .product(name: "Collections", package: "swift-collections")
            ]),
        .target(
            name: "LTVMPC",
            dependencies: [
                .product(name: "RealModule", package: "swift-numerics"),
                "LASwift",
                "SymbolicMath",
                .product(name: "Collections", package: "swift-collections"),
                "SwiftMPC",
            ]),
    ]
)
