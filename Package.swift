// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
	name: "combine-interception",
	platforms: [
		.iOS(.v13),
		.macOS(.v10_15),
		.tvOS(.v13),
		.macCatalyst(.v13),
		.watchOS(.v6)
	],
	products: [
		.library(
			name: "CombineInterception",
			type: .static,
			targets: ["CombineInterception"]
		)
	],
	dependencies: [
		.package(
			url: "https://github.com/capturecontext/swift-interception.git",
			.upToNextMinor(from: "0.2.0")
		)
	],
	targets: [
		.target(
			name: "CombineInterception",
			dependencies: [
				.product(
					name: "Interception",
					package: "swift-interception"
				)
			]
		),
		.testTarget(
			name: "CombineInterceptionTests",
			dependencies: [
				.target(name: "CombineInterception"),
			]
		),
	]
)
