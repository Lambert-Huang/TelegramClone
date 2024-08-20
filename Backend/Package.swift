// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Backend",
  platforms: [.macOS(.v12), .iOS(.v14)],
  products: [
    .library(
      name: "CountryProvider",
      targets: ["CountryProvider"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "CountryProvider",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
      ],
      resources: [
        .process("Resources")
      ]
    ),
  ]
)
