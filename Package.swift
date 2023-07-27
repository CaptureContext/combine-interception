// swift-tools-version:5.8

import PackageDescription

let package = Package(
  name: "combine-interception",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6)
  ],
  products: [
    .library(
      name: "CombineInterception",
      type: .static,
      targets: ["CombineInterception"]
    )
  ],
  targets: [
    .target(
      name: "CombineInterception",
      dependencies: [
        .target(name: "CombineRuntime")
      ]
    ),
    .target(name: "CombineRuntime")
  ]
)
