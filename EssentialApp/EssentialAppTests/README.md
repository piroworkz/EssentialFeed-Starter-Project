# EssentialAppTests

## Purpose
EssentialAppTests validates the wiring of the main application by exercising composed scenes with in-memory doubles. Acceptance tests assert correct behaviour under different connectivity and cache conditions.

## Architecture
The suite boots `SceneDelegate` with stubbed `HTTPClient` and `FeedStore` implementations to simulate online, offline, and cache scenarios. Utilities under `utils/` provide spies (`FeedImageLoaderSpy`, `HTTPClientStub`) and extensions that make UI assertions concise while tracking memory leaks.

## Key files
- `FeedAcceptanceTests.swift`: end-to-end acceptance coverage for feed loading and cache expiration.
- `SceneDelegateTests.swift`: verifies window configuration and lifecycle behaviour.
- `FeedUiIntegrationTests.swift`: exercises presenter-to-view wiring in isolation.

## Running
Use `xcodebuild -scheme EssentialApp -only-testing:EssentialAppTests test` from the repository root (or workspace) to execute the bundle. Group any new tests alongside the production feature they cover and keep helper code inside `utils/` to avoid duplicating spies across suites.
