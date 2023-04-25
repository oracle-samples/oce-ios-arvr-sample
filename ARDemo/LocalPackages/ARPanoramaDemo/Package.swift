// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import PackageDescription

let package = Package(
    name: "ARPanoramaDemo",
    platforms: [.iOS("16.0")],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ARPanoramaDemo",
            targets: ["ARPanoramaDemo"]),
    ],
    dependencies: [
        .package(name: "ARDemoCommon", path: "../ARDemoCommon"),
        .package(url: "https://github.com/oracle-samples/content-management-swift",
                 .upToNextMajor(from: Version(stringLiteral: "1.0.0")))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ARPanoramaDemo",
            dependencies: [
                "ARDemoCommon",
                .product(name: "OracleContentCore", package: "content-management-swift"),
                .product(name: "OracleContentDelivery", package: "content-management-swift")
            ]),
        .testTarget(
            name: "ARPanoramaDemoTests",
            dependencies: [
                "ARPanoramaDemo",
                .product(name: "OracleContentTest", package: "content-management-swift")
            ]),
    ]
)
