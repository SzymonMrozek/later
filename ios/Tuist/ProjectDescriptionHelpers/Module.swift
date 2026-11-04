import ProjectDescription

public let deploymentTargets: DeploymentTargets = .iOS("17.0")

/// A focused framework in `Modules/<group>/<name>`: `Sources`, plus `Resources` and `Tests` when it has them.
/// Dependencies are declared per module, and `tuist inspect dependencies` rejects any import that isn't.
public struct Module {
    public let name: String
    public let group: String
    public let dependencies: [String]
    public let hasResources: Bool
    public let hasTests: Bool

    public init(
        _ name: String,
        group: String,
        dependencies: [String] = [],
        hasResources: Bool = false,
        hasTests: Bool = false
    ) {
        self.name = name
        self.group = group
        self.dependencies = dependencies
        self.hasResources = hasResources
        self.hasTests = hasTests
    }

    public var testsName: String {
        "\(name)Tests"
    }

    public var targets: [Target] {
        let path = "Modules/\(group)/\(name)"
        let framework = Target.target(
            name: name,
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "dev.mrozek.later.\(name)",
            deploymentTargets: deploymentTargets,
            sources: ["\(path)/Sources/**"],
            resources: hasResources ? ["\(path)/Resources/**"] : nil,
            dependencies: dependencies.map { .target(name: $0) }
        )
        guard hasTests else {
            return [framework]
        }
        let tests = Target.target(
            name: testsName,
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.mrozek.later.\(testsName)",
            deploymentTargets: deploymentTargets,
            sources: ["\(path)/Tests/**"],
            dependencies: [.target(name: name)]
        )
        return [framework, tests]
    }
}
