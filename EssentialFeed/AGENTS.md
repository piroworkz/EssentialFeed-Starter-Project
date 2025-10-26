# Repository Guidelines

## Project Structure & Module Organization
Essential domain modules live under `EssentialFeed/`, grouped by feature folders (`Feed Api`, `FeedCache`, `FeedPresenter`). Keep related protocols, DTOs, and helpers next to the feature they support. Test targets mirror this layout: unit specs in `EssentialFeedTests/`, end-to-end checks in `EssentialFeedApiEndToEndTests/`, integration coverage in `EssentialFeedCacheIntegrationTests/`, and the iOS app plus UI harness in `EssentialFeediOS/` and `EssentialFeediOSTests/`. Shared UI components such as `FeedViewController.swift` live at the root for reuse across schemes.

## Build, Test, and Development Commands
- `xcodebuild -scheme EssentialFeediOS -destination 'platform=iOS Simulator,name=iPhone 15' build` builds the iOS app target and surfaces compile-time warnings quickly.
- `xcodebuild -scheme EssentialFeed -testPlan CI_iOS.xctestplan test` runs the full iOS unit, integration, and UI suites defined in the test plan.
- `xcodebuild -scheme EssentialFeed -testPlan CI_macOS.xctestplan test` validates the macOS configuration and should pass before merging cross-platform changes.

## Coding Style & Naming Conventions
Follow Swift defaults: four-space indentation, limit access with `private` where possible, and keep one top-level type per file that matches the file name (`LocalFeedLoader.swift`, `HTTPClient.swift`). Name tests using the `test_<scenario>_<expected>()` pattern adopted throughout `LoadFeedFromRemoteUseCaseTests`, and prefer intent-revealing factory helpers in extensions for fixtures.

## Testing Guidelines
Prefer isolated specs in feature-specific folders, backed by lightweight test doubles (`HTTPClientSpy`, local store stubs). Integration and end-to-end suites should only cover boundary behaviors such as cache expiration or remote contract validations. When adding new coverage, update the relevant `.xctestplan` to keep CI jobs in sync, and rerun `xcodebuild ... test` locally before pushing.

## Commit & Pull Request Guidelines
Write imperative, scope-focused commit messages (`Add FeedPresenter unit tests`, `Refactor Feed presentation`). Group related edits per commit, and keep refactors separate from behavior changes. Pull requests should summarize the change, link tracking issues, list validation steps (commands above), and include simulator screenshots whenever UI is affected.
