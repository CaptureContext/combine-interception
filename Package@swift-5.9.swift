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
		.watchOS(.v6),
	],
	products: [
		.library(
			name: "CombineInterception",
			type: .static,
			targets: ["CombineInterception"]
		),
		.library(
			name: "CombineInterceptionMacros",
			type: .static,
			targets: ["CombineInterceptionMacros"]
		),
	],
	dependencies: [
		.package(
			url: "https://github.com/capturecontext/swift-interception.git",
			.upToNextMinor(from: "0.4.4")
		),
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
		.target(
			name: "CombineInterceptionMacros",
			dependencies: [
				.target(name: "CombineInterception"),
				.product(
					name: "_InterceptionMacros",
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
		.testTarget(
			name: "CombineInterceptionMacrosTests",
			dependencies: [
				.target(name: "CombineInterceptionMacros"),
			]
		),
	]
)
