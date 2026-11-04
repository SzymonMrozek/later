import ProjectDescription
import ProjectDescriptionHelpers

/// The design system from design/Later.canvas: one module per token set and per component family,
/// so a screen imports only what it draws.
let designSystem: [Module] = [
    // Tokens
    Module("LaterColor", group: "DesignSystem", hasTests: true),
    Module("LaterTypography", group: "DesignSystem", hasResources: true, hasTests: true),
    Module("LaterSpacing", group: "DesignSystem"),
    Module("LaterRadius", group: "DesignSystem"),
    Module("LaterSize", group: "DesignSystem"),
    Module("LaterStroke", group: "DesignSystem"),
    Module("LaterShadow", group: "DesignSystem", dependencies: ["LaterColor"]),
    Module("LaterGlass", group: "DesignSystem", dependencies: ["LaterColor", "LaterShadow", "LaterStroke"]),

    // Actions
    Module(
        "LaterButton",
        group: "DesignSystem",
        dependencies: ["LaterColor", "LaterSize", "LaterSpacing", "LaterTypography"]
    ),
    Module(
        "LaterIconButton",
        group: "DesignSystem",
        dependencies: ["LaterColor", "LaterGlass", "LaterSize", "LaterTypography"]
    ),
    Module("LaterWordmark", group: "DesignSystem", dependencies: ["LaterColor", "LaterTypography"]),

    // Selection
    Module(
        "LaterChip",
        group: "DesignSystem",
        dependencies: ["LaterColor", "LaterSpacing", "LaterStroke", "LaterTypography"]
    ),
    Module(
        "LaterSegmentedControl",
        group: "DesignSystem",
        dependencies: ["LaterColor", "LaterShadow", "LaterSpacing", "LaterTypography"]
    ),
    Module(
        "LaterDurationPicker",
        group: "DesignSystem",
        dependencies: ["LaterColor", "LaterRadius", "LaterSize", "LaterSpacing", "LaterStroke", "LaterTypography"]
    ),
    Module(
        "LaterOptionCard",
        group: "DesignSystem",
        dependencies: ["LaterColor", "LaterRadius", "LaterSpacing", "LaterStroke", "LaterTypography"]
    ),

    // Forms and lists
    Module(
        "LaterTextField",
        group: "DesignSystem",
        dependencies: ["LaterColor", "LaterRadius", "LaterSize", "LaterSpacing", "LaterTypography"]
    ),
    Module("LaterListRow", group: "DesignSystem", dependencies: ["LaterColor", "LaterSpacing", "LaterTypography"]),
    Module("LaterSectionHeader", group: "DesignSystem", dependencies: ["LaterColor", "LaterTypography"]),
    Module(
        "LaterComparisonTable",
        group: "DesignSystem",
        dependencies: ["LaterColor", "LaterRadius", "LaterSize", "LaterSpacing", "LaterStroke", "LaterTypography"]
    ),

    // Articles
    Module(
        "LaterSourceIcon",
        group: "DesignSystem",
        dependencies: ["LaterColor", "LaterRadius", "LaterSize", "LaterTypography"],
        hasTests: true
    ),
    Module(
        "LaterStatusTag",
        group: "DesignSystem",
        dependencies: ["LaterColor", "LaterRadius", "LaterSpacing", "LaterTypography"]
    ),
    Module(
        "LaterArticleThumb",
        group: "DesignSystem",
        dependencies: ["LaterColor", "LaterRadius", "LaterSize", "LaterTypography"]
    ),
    Module(
        "LaterArticleRow",
        group: "DesignSystem",
        dependencies: [
            "LaterArticleThumb", "LaterColor", "LaterSourceIcon", "LaterSpacing", "LaterStatusTag", "LaterTypography",
        ]
    ),
    Module(
        "LaterQueueRow",
        group: "DesignSystem",
        dependencies: [
            "LaterArticleThumb", "LaterColor", "LaterRadius", "LaterSize", "LaterSpacing", "LaterTypography",
        ]
    ),
    Module("LaterPrepProgress", group: "DesignSystem", dependencies: ["LaterColor", "LaterSpacing", "LaterTypography"]),

    // Listening
    Module(
        "LaterSessionBar",
        group: "DesignSystem",
        dependencies: ["LaterColor", "LaterRadius", "LaterSize", "LaterSpacing"],
        hasTests: true
    ),
    Module(
        "LaterScrubber",
        group: "DesignSystem",
        dependencies: ["LaterColor", "LaterRadius", "LaterSize", "LaterSpacing", "LaterTypography"],
        hasTests: true
    ),
    Module(
        "LaterPlayerControls",
        group: "DesignSystem",
        dependencies: ["LaterColor", "LaterGlass", "LaterSize", "LaterSpacing", "LaterTypography"]
    ),
    Module(
        "LaterMiniPlayer",
        group: "DesignSystem",
        dependencies: [
            "LaterArticleThumb", "LaterColor", "LaterGlass", "LaterSize", "LaterSpacing", "LaterTypography",
        ]
    ),

    // Navigation and feedback
    Module(
        "LaterNavBar",
        group: "DesignSystem",
        dependencies: ["LaterColor", "LaterIconButton", "LaterSize", "LaterTypography"]
    ),
    Module(
        "LaterTabBar",
        group: "DesignSystem",
        dependencies: ["LaterColor", "LaterGlass", "LaterSpacing", "LaterTypography"]
    ),
]

let modules = designSystem

let project = Project(
    name: "Later",
    options: .options(automaticSchemesOptions: .disabled),
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
    ] + modules.flatMap(\.targets),
    schemes: [
        .scheme(
            name: "Later",
            buildAction: .buildAction(targets: ["Later"]),
            testAction: .targets(
                (["LaterTests"] + modules.filter(\.hasTests).map(\.testsName))
                    .map { .testableTarget(target: .target($0)) }
            ),
            runAction: .runAction(executable: "Later")
        ),
    ]
)
