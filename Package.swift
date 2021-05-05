// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Unconstrained-Minimization",
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "0.0.8"),
        .package(url: "https://github.com/ianruh/LASwift.git", .branch("linux")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Unconstrained-Minimization",
            dependencies: [
                .product(name: "RealModule", package: "swift-numerics"),
                "LASwift",
            ]),
//        .target(
//                name: "SymbolicMath",
//                dependencies: [.product(name: "RealModule", package: "swift-numerics"), "LASwift"]),
        .testTarget(
            name: "Unconstrained-MinimizationTests",
            dependencies: ["Unconstrained-Minimization"]),
    ]
)
