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
    .standalone("BuildConfiguration", group: .utilities, tests: .plain),
    .split(
        "HTTPNetworking",
        group: .utilities,
        implementation: ["BuildConfiguration", "DependencyInjection"],
        implementationTests: .with(["HTTPNetworkingInterface"])
    ),
    .split("Keychain", group: .utilities, implementation: ["DependencyInjection"]),
    .split(
        "SessionStorage",
        group: .utilities,
        interface: ["Session"],
        implementation: ["Account", "DependencyInjection", "KeychainInterface", "Session"],
        implementationTests: .with([
            "Account", "DependencyInjection", "DependencyInjectionTestSupport", "KeychainInterface", "Session",
            "SessionStorageInterface",
        ])
    ),
    .split(
        "DeviceID",
        group: .utilities,
        implementation: ["DependencyInjection", "KeychainInterface"],
        implementationTests: .with([
            "DependencyInjection", "DependencyInjectionTestSupport", "DeviceIDInterface", "KeychainInterface",
        ])
    ),
    .split("AppleSignIn", group: .utilities, implementation: ["DependencyInjection"]),
    .split(
        "BackgroundTask",
        group: .utilities,
        implementation: ["DependencyInjection"],
        implementationTests: .plain
    ),
    // The composition root: the only module that selects implementations.
    .standalone(
        "AppComposition",
        group: .utilities,
        dependencies: [
            "AppleSignInImplementation", "AuthenticationImplementation", "AuthenticationInterface",
            "BackgroundTaskImplementation", "Coordinator", "DependencyInjection", "DeviceIDImplementation",
            "HTTPNetworkingImplementation", "KeychainImplementation", "LaterCatalog", "LoginImplementation",
            "LoginInterface", "SessionResourceImplementation", "SessionStorageImplementation",
        ],
        tests: .with([
            "Account", "AuthenticationInterface", "Coordinator", "DependencyInjection",
            "DependencyInjectionTestSupport", "LoginInterface",
        ])
    ),
]

let models: [Module] = [
    .standalone("Account", group: .models, tests: .plain),
    .standalone("Session", group: .models, dependencies: ["Account"]),
]

let services: [Module] = [
    // The Later API's session endpoints: requests, responses and their mapping to Session.
    .split(
        "SessionResource",
        group: .services,
        interface: ["Session"],
        implementation: ["Account", "DependencyInjection", "HTTPNetworkingInterface", "Session"],
        implementationTests: .with([
            "Account", "DependencyInjection", "DependencyInjectionTestSupport", "HTTPNetworkingInterface", "Session",
            "SessionResourceInterface",
        ])
    ),
    .split(
        "Authentication",
        group: .services,
        interface: ["Account"],
        implementation: [
            "Account", "AppleSignInInterface", "BackgroundTaskInterface", "DependencyInjection", "DeviceIDInterface",
            "Session", "SessionResourceInterface", "SessionStorageInterface",
        ],
        implementationTests: .with([
            "Account", "AppleSignInInterface", "AuthenticationInterface", "BackgroundTaskInterface",
            "DependencyInjection", "DependencyInjectionTestSupport", "DeviceIDInterface", "Session",
            "SessionResourceInterface", "SessionStorageInterface",
        ])
    ),
]

let scenes: [Module] = [
    .split(
        "Login",
        group: .scenes,
        interface: ["Coordinator"],
        implementation: [
            "Account", "AuthenticationInterface", "Coordinator", "DependencyInjection", "LaterButton", "LaterColor",
            "LaterNotice", "LaterSpacing", "LaterStepIndicator", "LaterTypography", "LaterWordmark",
        ],
        hasResources: true,
        implementationTests: .with([
            "Account", "AuthenticationInterface", "DependencyInjection", "DependencyInjectionTestSupport",
        ])
    ),
]

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
            bundleId: "com.later",
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "Later",
                "UILaunchScreen": [:],
                // Articles keep playing with the screen locked.
                "UIBackgroundModes": ["audio"],
                // Read by BuildConfiguration. scripts/ios.sh points it at this worktree's server.
                "LaterAPIBaseURL": "$(LATER_API_BASE_URL)",
                // The development server runs on localhost over plain HTTP.
                "NSAppTransportSecurity": ["NSAllowsLocalNetworking": true],
                // A device build reaches the development server on the Mac over the local network.
                "NSLocalNetworkUsageDescription": "Later łączy się z serwerem deweloperskim w sieci lokalnej.",
            ]),
            sources: ["Later/Sources/**"],
            resources: ["Later/Resources/**"],
            entitlements: "Later/Later.entitlements",
            dependencies: [.target(name: "AppComposition")],
            settings: .settings(base: [
                "LATER_API_BASE_URL": .string(Environment.laterApiBaseUrl.getString(default: "http://localhost:4000")),
                // Device builds use the Ad Hoc profile from crem.yaml; simulator builds sign locally.
                "DEVELOPMENT_TEAM": "KSMJS9552W",
                "CODE_SIGN_STYLE": "Manual",
                "CODE_SIGN_IDENTITY[sdk=iphonesimulator*]": "-",
                "CODE_SIGN_IDENTITY[sdk=iphoneos*]": "Apple Distribution",
                "PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]": "com.later AdHoc",
            ])
        ),
    ] + modules.flatMap(\.targets),
    schemes: [
        .scheme(
            name: "Later",
            buildAction: .buildAction(targets: ["Later"]),
            testAction: .targets(modules.flatMap(\.testTargetNames).map { .testableTarget(target: .target($0)) }),
            runAction: .runAction(executable: "Later")
        ),
    ]
)
