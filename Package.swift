// swift-tools-version: 6.3

// © 2025–2026 John Gary Pusey (see LICENSE.md)

import PackageDescription

let swiftSettings: [SwiftSetting] = [.defaultIsolation(nil),
                                     .enableUpcomingFeature("ExistentialAny"),
                                     .enableUpcomingFeature("ImmutableWeakCaptures"),
                                     .enableUpcomingFeature("InferIsolatedConformances"),
                                     .enableUpcomingFeature("InternalImportsByDefault"),
                                     .enableUpcomingFeature("MemberImportVisibility"),
                                     .enableUpcomingFeature("NonisolatedNonsendingByDefault")]

let package = Package(name: "IvorSMPTE",
                      platforms: [.iOS(.v18),
                                  .macOS(.v15)],
                      products: [.library(name: "IvorSMPTE",
                                          targets: ["IvorSMPTE"])],
                      dependencies: [.package(url: "https://github.com/eBardX/XestiNumbers.git",
                                              .upToNextMajor(from: "1.3.0"))],
                      targets: [.target(name: "IvorSMPTE",
                                        dependencies: [.product(name: "XestiNumbers",
                                                                package: "XestiNumbers")],
                                        swiftSettings: swiftSettings),
                                .testTarget(name: "IvorSMPTETests",
                                            dependencies: [.target(name: "IvorSMPTE"),
                                                           .product(name: "XestiNumbers",
                                                                    package: "XestiNumbers")],
                                            swiftSettings: swiftSettings)],
                      swiftLanguageModes: [.v6])
