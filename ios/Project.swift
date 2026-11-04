import ProjectDescription
import ProjectDescriptionHelpers

// The module graph. Modules/README.md explains the groups and the rules; `mise run ios:lint` enforces them.

let utilities: [Module] = [
    .standalone("DependencyInjection", group: .utilities, tests: .plain),
    .standalone(
        "DependencyInjectionTestSupport",
        group: .utilities,
        dependencies: ["DependencyInjection"],
        isTestSupport: true
    ),
    .standalone("Coordinator", group: .utilities),
]

let models: [Module] = []

let services: [Module] = []

let scenes: [Module] = []

let uiComponents: [Module] = [
    // Tokens
    .standalone("LaterColor", group: .uiComponents, tests: .plain),
    .standalone("LaterTypography", group: .uiComponents, hasResources: true, tests: .plain),
    .standalone("LaterSpacing", group: .uiComponents),
    .standalone("LaterRadius", group: .uiComponents),
    .standalone("LaterSize", group: .uiComponents),
    .standalone("LaterStroke", group: .uiComponents),
    .standalone("LaterShadow", group: .uiComponents, dependencies: ["LaterColor"]),
    .standalone("LaterGlass", group: .uiComponents, dependencies: ["LaterColor", "LaterShadow", "LaterStroke"]),

    // Actions
    .standalone(
        "LaterButton",
        group: .uiComponents,
        dependencies: ["LaterColor", "LaterSize", "LaterSpacing", "LaterTypography"]
    ),
    .standalone(
        "LaterIconButton",
        group: .uiComponents,
        dependencies: ["LaterColor", "LaterGlass", "LaterSize", "LaterTypography"]
    ),
    .standalone("LaterWordmark", group: .uiComponents, dependencies: ["LaterColor", "LaterTypography"]),

    // Selection
    .standalone(
        "LaterChip",
        group: .uiComponents,
        dependencies: ["LaterColor", "LaterSpacing", "LaterStroke", "LaterTypography"]
    ),
    .standalone(
        "LaterSegmentedControl",
        group: .uiComponents,
        dependencies: ["LaterColor", "LaterShadow", "LaterSpacing", "LaterTypography"]
    ),
    .standalone(
        "LaterDurationPicker",
        group: .uiComponents,
        dependencies: ["LaterColor", "LaterRadius", "LaterSize", "LaterSpacing", "LaterStroke", "LaterTypography"]
    ),
    .standalone(
        "LaterOptionCard",
        group: .uiComponents,
        dependencies: ["LaterColor", "LaterRadius", "LaterSpacing", "LaterStroke", "LaterTypography"]
    ),

    // Forms and lists
    .standalone(
        "LaterTextField",
        group: .uiComponents,
        dependencies: ["LaterColor", "LaterRadius", "LaterSize", "LaterSpacing", "LaterTypography"]
    ),
    .standalone("LaterListRow", group: .uiComponents, dependencies: ["LaterColor", "LaterSpacing", "LaterTypography"]),
    .standalone("LaterSectionHeader", group: .uiComponents, dependencies: ["LaterColor", "LaterTypography"]),
    .standalone(
        "LaterComparisonTable",
        group: .uiComponents,
        dependencies: ["LaterColor", "LaterRadius", "LaterSize", "LaterSpacing", "LaterStroke", "LaterTypography"]
    ),

    // Articles
    .standalone(
        "LaterSourceIcon",
        group: .uiComponents,
        dependencies: ["LaterColor", "LaterRadius", "LaterSize", "LaterTypography"],
        tests: .plain
    ),
    .standalone(
        "LaterStatusTag",
        group: .uiComponents,
        dependencies: ["LaterColor", "LaterRadius", "LaterSpacing", "LaterTypography"]
    ),
    .standalone(
        "LaterArticleThumb",
        group: .uiComponents,
        dependencies: ["LaterColor", "LaterRadius", "LaterSize", "LaterTypography"]
    ),
    .standalone(
        "LaterArticleRow",
        group: .uiComponents,
        dependencies: [
            "LaterArticleThumb", "LaterColor", "LaterSourceIcon", "LaterSpacing", "LaterStatusTag", "LaterTypography",
        ]
    ),
    .standalone(
        "LaterQueueRow",
        group: .uiComponents,
        dependencies: [
            "LaterArticleThumb", "LaterColor", "LaterRadius", "LaterSize", "LaterSpacing", "LaterTypography",
        ]
    ),
    .standalone(
        "LaterPrepProgress",
        group: .uiComponents,
        dependencies: ["LaterColor", "LaterSpacing", "LaterTypography"]
    ),

    // Listening
    .standalone(
        "LaterSessionBar",
        group: .uiComponents,
        dependencies: ["LaterColor", "LaterRadius", "LaterSize", "LaterSpacing"],
        tests: .plain
    ),
    .standalone(
        "LaterScrubber",
        group: .uiComponents,
        dependencies: ["LaterColor", "LaterRadius", "LaterSize", "LaterSpacing", "LaterTypography"],
        tests: .plain
    ),
    .standalone(
        "LaterPlayerControls",
        group: .uiComponents,
        dependencies: ["LaterColor", "LaterGlass", "LaterSize", "LaterSpacing", "LaterTypography"]
    ),
    .standalone(
        "LaterMiniPlayer",
        group: .uiComponents,
        dependencies: [
            "LaterArticleThumb", "LaterColor", "LaterGlass", "LaterSize", "LaterSpacing", "LaterTypography",
        ]
    ),

    // Navigation and feedback
    .standalone(
        "LaterNavBar",
        group: .uiComponents,
        dependencies: ["LaterColor", "LaterIconButton", "LaterSize", "LaterTypography"]
    ),
    .standalone(
        "LaterTabBar",
        group: .uiComponents,
        dependencies: ["LaterColor", "LaterGlass", "LaterSpacing", "LaterTypography"]
    ),
    .standalone("LaterStepIndicator", group: .uiComponents, dependencies: ["LaterColor", "LaterSize", "LaterSpacing"]),
    .standalone(
        "LaterNotice",
        group: .uiComponents,
        dependencies: ["LaterColor", "LaterRadius", "LaterSpacing", "LaterTypography"]
    ),
    .standalone(
        "LaterSheet",
        group: .uiComponents,
        dependencies: ["LaterColor", "LaterRadius", "LaterSpacing", "LaterTypography"]
    ),

    // Design review: every token and component, one page per group or family
    .standalone("LaterCatalog", group: .uiComponents, dependencies: [
        "LaterArticleRow", "LaterArticleThumb", "LaterButton", "LaterChip", "LaterColor", "LaterComparisonTable",
        "LaterDurationPicker", "LaterGlass", "LaterIconButton", "LaterListRow", "LaterMiniPlayer", "LaterNavBar",
        "LaterNotice", "LaterOptionCard", "LaterPlayerControls", "LaterPrepProgress", "LaterQueueRow", "LaterRadius",
        "LaterScrubber", "LaterSectionHeader", "LaterSegmentedControl", "LaterSessionBar", "LaterShadow", "LaterSheet",
        "LaterSize", "LaterSourceIcon", "LaterSpacing", "LaterStatusTag", "LaterStepIndicator", "LaterStroke",
        "LaterTabBar", "LaterTextField", "LaterTypography", "LaterWordmark",
    ]),
]

let modules = utilities + models + services + scenes + uiComponents

let project = Project(
    name: "Later",
    options: .options(automaticSchemesOptions: .disabled),
    settings: .settings(base: [
        "SWIFT_VERSION": "6.0",
        // Everything runs on the main actor unless a declaration says otherwise.
        "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
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
            resources: ["Later/Resources/**"],
            dependencies: [.target(name: "LaterCatalog")]
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
                (["LaterTests"] + modules.flatMap(\.testTargetNames)).map { .testableTarget(target: .target($0)) }
            ),
            runAction: .runAction(executable: "Later")
        ),
    ]
)
