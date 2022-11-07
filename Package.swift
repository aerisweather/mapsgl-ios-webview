// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MapsGLWebView",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "MapsGLWebView",
            targets: ["MapsGLWebView"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Lision/WKWebViewJavascriptBridge.git", branch: "master")
    ],
    targets: [
        .target(
            name: "MapsGLWebView",
            dependencies: ["WKWebViewJavascriptBridge"],
            path: "Sources/MapsGLWebView",
            resources: [.copy("HTML/mapview.html")]
        ),
        .testTarget(
            name: "MapsGLWebViewTests",
            dependencies: ["MapsGLWebView"]),
    ],
    swiftLanguageVersions: [.v5]
)
