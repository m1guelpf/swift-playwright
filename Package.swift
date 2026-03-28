// swift-tools-version: 6.1

import PackageDescription

let package = Package(
	name: "Playwright",
	platforms: [.macOS(.v15)],
	products: [
		.library(name: "Playwright", targets: ["Playwright"]),
		.library(name: "PlaywrightTesting", targets: ["PlaywrightTesting"]),
		.plugin(name: "PlaywrightDriverPlugin", targets: ["PlaywrightDriverPlugin"]),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
	],
	targets: [
		// Library
		.target(name: "Playwright", path: "./src/core", resources: [.copy("drivers")]),
		.target(name: "PlaywrightTesting", dependencies: ["Playwright"], path: "./src/testing"),

		// Driver Downloader
		.executableTarget(
			name: "DownloadDriver",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			],
			path: "./cli"
		),
		.plugin(
			name: "PlaywrightDriverPlugin",
			capability: .command(
				intent: .custom(
					verb: "install-playwright",
					description: "Download the Playwright driver for browser automation"
				),
				permissions: [
					.writeToPackageDirectory(reason: "Downloads the Playwright driver"),
					.allowNetworkConnections(
						scope: .all(ports: [443]),
						reason: "Downloads the Playwright driver from cdn.playwright.dev"
					),
				]
			),
			dependencies: ["DownloadDriver"],
			path: "./plugin"
		),

		// Tests
		.testTarget(name: "PlaywrightTests", dependencies: ["Playwright", "PlaywrightTesting"], path: "./tests"),
	],
	swiftLanguageModes: [.v6]
)
