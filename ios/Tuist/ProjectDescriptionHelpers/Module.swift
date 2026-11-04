import ProjectDescription

public let deploymentTargets: DeploymentTargets = .iOS("17.0")

/// An architectural module in `Modules/<group>/<name>`. It builds one or more static frameworks,
/// each from a directory with `Sources`, and `Resources` and `Tests` when it has them.
///
/// - A standalone module is one target from `Sources`.
/// - A split module is `<Name>Interface` from `Interface/` and `<Name>Implementation` from
///   `Implementation/`; the implementation always depends on its interface.
///
/// Dependencies are declared per target. `mise run ios:lint` rejects imports that differ from them
/// (`tuist inspect dependencies`) and edges the architecture doesn't allow (`scripts/ios-module-rules.py`).
public struct Module {
    public enum Group: String {
        /// Complete UI features with their navigation.
        case scenes = "Scenes"
        /// Reusable views and visual building blocks, including the design system.
        case uiComponents = "UIComponents"
        /// Application-specific business logic and domain state.
        case services = "Services"
        /// Product-independent infrastructure.
        case utilities = "Utilities"
        /// Shared domain values.
        case models = "Models"
    }

    public struct Tests {
        /// What the tests import besides the target they test.
        public let dependencies: [String]

        public static let plain = Tests(dependencies: [])

        public static func with(_ dependencies: [String]) -> Tests {
            Tests(dependencies: dependencies)
        }
    }

    struct Part {
        let name: String
        let directory: String
        let dependencies: [String]
        let hasResources: Bool
        let tests: Tests?
        /// Test helpers, such as test traits, that import Testing outside a test target.
        var isTestSupport = false
    }

    public let name: String
    public let group: Group
    let parts: [Part]

    public static func standalone(
        _ name: String,
        group: Group,
        dependencies: [String] = [],
        hasResources: Bool = false,
        tests: Tests? = nil,
        isTestSupport: Bool = false
    ) -> Module {
        let path = "Modules/\(group.rawValue)/\(name)"
        let parts = [
            Part(
                name: name,
                directory: path,
                dependencies: dependencies,
                hasResources: hasResources,
                tests: tests,
                isTestSupport: isTestSupport
            ),
        ]
        return Module(name: name, group: group, parts: parts)
    }

    public static func split(
        _ name: String,
        group: Group,
        interface: [String] = [],
        implementation: [String] = [],
        hasResources: Bool = false,
        interfaceTests: Tests? = nil,
        implementationTests: Tests? = nil
    ) -> Module {
        let path = "Modules/\(group.rawValue)/\(name)"
        let interfaceName = "\(name)Interface"
        return Module(name: name, group: group, parts: [
            Part(
                name: interfaceName,
                directory: "\(path)/Interface",
                dependencies: interface,
                hasResources: false,
                tests: interfaceTests
            ),
            Part(
                name: "\(name)Implementation",
                directory: "\(path)/Implementation",
                dependencies: [interfaceName] + implementation,
                hasResources: hasResources,
                tests: implementationTests
            ),
        ])
    }

    public var targets: [Target] {
        parts.flatMap { part -> [Target] in
            let framework = Target.target(
                name: part.name,
                destinations: .iOS,
                product: .staticFramework,
                bundleId: "dev.mrozek.later.\(part.name)",
                deploymentTargets: deploymentTargets,
                sources: ["\(part.directory)/Sources/**"],
                resources: part.hasResources ? ["\(part.directory)/Resources/**"] : nil,
                dependencies: part.dependencies.map { .target(name: $0) },
                settings: part.isTestSupport ? .settings(base: ["ENABLE_TESTING_SEARCH_PATHS": "YES"]) : nil
            )
            guard let tests = part.tests else {
                return [framework]
            }
            let testTarget = Target.target(
                name: "\(part.name)Tests",
                destinations: .iOS,
                product: .unitTests,
                bundleId: "dev.mrozek.later.\(part.name)Tests",
                deploymentTargets: deploymentTargets,
                sources: ["\(part.directory)/Tests/**"],
                dependencies: ([part.name] + tests.dependencies).map { .target(name: $0) }
            )
            return [framework, testTarget]
        }
    }

    public var testTargetNames: [String] {
        parts.filter { $0.tests != nil }.map { "\($0.name)Tests" }
    }
}
