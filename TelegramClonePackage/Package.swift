// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "TelegramClonePackage",
  platforms: [.macOS(.v12), .iOS(.v14)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "Animations",
      targets: ["Animations"]
    ),
    .library(
      name: "AuthFeature",
      targets: ["AuthFeature"]
    ),
    .library(
      name: "ColorPalette",
      targets: ["ColorPalette"]
    ),
    .library(
      name: "RootFeature",
      targets: ["RootFeature"]
    ),
    .library(
      name: "UIComponents",
      targets: ["UIComponents"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", branch: "master"),
    .package(url: "https://github.com/pointfreeco/swift-perception.git", from: "1.3.4"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections.git", from: "1.1.0"),
    .package(url: "https://github.com/pointfreeco/swift-tagged.git", from: "0.10.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-navigation.git", from: "2.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "1.5.4"),
    .package(path: "../Backend"),
  ],
  targets: [
    .target(name: "Animations"),
    .target(
      name: "AuthFeature",
      dependencies: [
        "Animations",
        "ColorPalette",
        "UIComponents",
        .product(
          name: "CountryProvider",
          package: "Backend"
        ),
        .product(
          name: "SwiftUIX",
          package: "SwiftUIX"
        ),
        .product(
          name: "Perception",
          package: "swift-perception"
        ),
        .product(
          name: "Dependencies",
          package: "swift-dependencies"
        ),
        .product(
          name: "CasePaths",
          package: "swift-case-paths"
        ),
        .product(
          name: "SwiftNavigation",
          package: "swift-navigation"
        ),
      ]
    ),
    .target(
      name: "ColorPalette",
      dependencies: [
        .product(
          name: "SwiftUIX",
          package: "SwiftUIX"
        ),
      ]
    ),
    .target(
      name: "RootFeature",
      dependencies: [
        "AuthFeature",
        .product(
          name: "SwiftUIX",
          package: "SwiftUIX"
        ),
        .product(
          name: "Perception",
          package: "swift-perception"
        ),
        .product(
          name: "Dependencies",
          package: "swift-dependencies"
        ),
        .product(
          name: "SwiftNavigation",
          package: "swift-navigation"
        ),
        .product(
          name: "CasePaths",
          package: "swift-case-paths"
        ),
      ]
    ),
    .target(
      name: "UIComponents",
      dependencies: [
        "ColorPalette",
        .product(
          name: "SwiftUIX",
          package: "SwiftUIX"
        ),
        .product(
          name: "SwiftUINavigation",
          package: "swift-navigation"
        ),
      ]
    ),
  ]
)
