// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let packageDependencies: [PackageDescription.Package.Dependency] = {
    #if os(Linux)
    [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.9.0")
    ]
    #elseif os(macOS)
    []
    #else
    []
    #endif
}()

let targetDependencies: [PackageDescription.Target.Dependency] = {
    #if os(Linux)
    [
        .product(name: "AsyncHTTPClient", package: "async-http-client")
    ]
    #elseif os(macOS)
    []
    #else
    []
    #endif
}()

let excludes: [String] = {
    #if os(Linux)
    [
        "Implementation/macOS"
    ]
    #elseif os(macOS)
    [
        "Implementation/linux"
    ]
    #else
    []
    #endif
}()

let package = Package(
    name: "AsyncHTTPKit",
    platforms: [
        .macOS(.v15),
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "AsyncHTTPKit",
            targets: ["AsyncHTTPKit"]),
    ],
    dependencies: packageDependencies,
    targets: [
        .target(
            name: "AsyncHTTPKit",
            dependencies: targetDependencies,
            exclude: excludes
        ),
        .testTarget(
            name: "AsyncHTTPKitTests",
            dependencies: ["AsyncHTTPKit"]
        ),
    ]
)
