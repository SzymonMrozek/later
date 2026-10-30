import ProjectDescription

let deploymentTargets: DeploymentTargets = .iOS("17.0")

let project = Project(
    name: "Later",
    settings: .settings(base: [
        "SWIFT_VERSION": "6.0",
        "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
    ]),
    targets: [
        .target(
            name: "Later",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.mrozek.later",
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "Later",
                "UILaunchScreen": [:],
                // Articles keep playing with the screen locked.
                "UIBackgroundModes": ["audio"],
            ]),
            sources: ["Later/Sources/**"],
            resources: ["Later/Resources/**"]
        ),
        .target(
            name: "LaterTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.mrozek.later.tests",
            deploymentTargets: deploymentTargets,
            sources: ["Later/Tests/**"],
            dependencies: [.target(name: "Later")]
        ),
    ]
)
