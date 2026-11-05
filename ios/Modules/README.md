# Modules

Every part of the app is a module with one responsibility, a small public contract and
declared dependencies. [`Project.swift`](../Project.swift) lists them; `mise run ios:lint`
rejects imports that aren't declared and edges the rules below don't allow.

```text
Later (app) ──▶ AppComposition ──▶ every *Implementation          selects what runs
                      │
Scenes        Login                                              view model, view, interactor, coordinator
Services      Authentication                                     product logic and domain state
              SessionResource                                    an API resource: endpoints, bodies, mapping
Models        Account · Session                                  domain values, no server types
Utilities     DependencyInjection · Coordinator · BuildConfiguration
              HTTPNetworking · Keychain · SessionStorage
              DeviceID · AppleSignIn · BackgroundTask            product-independent infrastructure

              Login ──▶ Authentication ──▶ SessionResource ──▶ HTTPNetworking
                                       ├─▶ SessionStorage  ──▶ Keychain
                                       ├─▶ DeviceID        ──▶ Keychain
                                       ├─▶ AppleSignIn
                                       └─▶ BackgroundTask       (every arrow: an Interface)
UIComponents  the design system (README.md there)                  reusable views
```

## Groups

| Group | Holds | Example |
| --- | --- | --- |
| `Scenes` | A complete feature: screens, coordinator, interactor, copy. | `Login` |
| `Services` | Later's own business logic and domain state, and the resources that reach the API. | `Authentication`, `SessionResource` |
| `Models` | Shared domain values. They never mirror a server response. | `Account`, `Session` |
| `Utilities` | Infrastructure that would work in any app: DI, HTTP, keychain, configuration. | `HTTPNetworking` |
| `UIComponents` | Reusable views, including the design system. | `LaterButton` |

The group is where a module lives, not a layer: any module may depend on any other's
contract when the product needs it.

## Shapes

- **Split** (`Interface/`, `Implementation/`): for scenes, services and utilities whose consumers
  should not know what implements them. The interface holds entry points, protocols and the values
  they exchange; nothing else is public.
- **Standalone** (`Sources/`): one target that exposes concrete types, such as a model, a token set
  or a view.

Each target directory has `Sources`, and `Resources` and `Tests` when it needs them.

## Rules

1. **Only `AppComposition` depends on an `*Implementation`**, besides that implementation's tests.
   Everything else depends on interfaces. The app target depends on `AppComposition` alone.
2. **The API goes through resources.** A `<Name>Resource` module owns a group of endpoints: its
   interface speaks domain values (`SessionResource.createGuestSession(deviceID:) -> Session`); its
   implementation holds the paths, request and response bodies and their mapping, and calls the
   HTTP client. Response types never leave it, so an API change stops there. Services call resources,
   never the HTTP client. A resource that needs a signed-in account takes the access token as a
   parameter; services get it through `AuthenticationService.authorized`, which refreshes the session
   before it expires and once after a 401. One refresh runs at a time, as a background task, and
   retries until the API answers.
3. **Each implementation registers itself.** `<Name>ImplementationModule.register()` binds its
   contracts in `DependencyInjectionContainer.shared`; `AppCompositionModule.register()` calls them all,
   in one visible list.
4. **Scenes start through entry points.** A caller attaches the destination's `<Name>EntryPoint` to
   its navigation controller and starts the coordinator it returns; it never builds another scene's
   views or interactors.
5. **Inside a scene:** the view reads an observable view model and sends actions to the interactor;
   the interactor does the work, updates the view model and asks the coordinator to navigate. The
   interactor isn't observable, and views and interactors never get navigation controllers or entry
   points.

   ```text
   View ──actions──▶ Interactor ──▶ Coordinator ──▶ UIKit
     ▲                   │
     └── LoginViewModel ◀┘ state
   ```

## Dependency injection

```swift
// The implementation binds its contract:
DependencyInjectionContainer.shared.register(.lazy { LoginEntryPointImpl() }, for: LoginEntryPoint.self)

// A consumer resolves it where it's used:
@Dependency var authentication: AuthenticationService
```

A dependency one function reads is a local `@Dependency var` in that function; one several
members read is a stored `@Dependency private var`. Tests use the
`.dependencyContainer` trait from `DependencyInjectionTestSupport` and register stubs on
`DependencyInjectionContainer.testScoped`.

## Concurrency

Every module defaults to the main actor (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`), so
contracts and their implementations are main-actor unless they say otherwise. `async` work such as
HTTP requests suspends without blocking it. Mark `nonisolated` what must run anywhere: pure value
types and helpers that cross isolation domains (`Account`, `Session`, request and response bodies),
and infrastructure that tests reach from outside the main actor (the dependency container).

## Adding a module

Add `.standalone(...)` or `.split(...)` to its group in [`Project.swift`](../Project.swift) with
the targets it imports, create its directories, run `mise run ios:generate`, and register its
implementation in `AppCompositionModule.register()`.
