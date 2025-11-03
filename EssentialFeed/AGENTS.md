# Repository Guidelines

## Project Structure & Module Organization
Core production code lives under `EssentialFeed/EssentialFeed/`, grouped by feature directories such as `Feed/API`, `Feed/Cache`, and `Feed/Image`. Keep each module self-contained with its protocols, DTOs, and presenters beside the implementation. iOS presentation code resides in `EssentialFeediOS/`, while shared app wiring for the acceptance target is in `EssentialApp/`. Tests mirror the production layout: unit suites in `EssentialFeedTests/`, end-to-end scenarios in `EssentialFeedApiEndToEndTests/`, cache integration checks in `EssentialFeedCacheIntegrationTests/`, and UI specs in `EssentialFeediOSTests/`. Assets and launch resources stay inside the corresponding `Resources` folders managed by Xcode.

## Build, Test, and Development Commands
- `xcodebuild -scheme EssentialFeediOS -destination 'platform=iOS Simulator,name=iPhone 15' build` to validate the app target compiles and surfaces warnings.
- `xcodebuild -scheme EssentialFeed -testPlan CI_iOS.xctestplan test` to run the full API, cache, and UI pipeline used by CI.
- `xcodebuild -scheme EssentialFeed -testPlan CI_macOS.xctestplan test` before submitting cross-platform fixes.
Run commands from the repository root so derived data aligns with the shared Xcode project.

## Coding Style & Naming Conventions
Use Swift’s four-space indentation, keep one type per file, and match filenames to types (`FeedImagePresenter.swift`). Mark collaborators `final` by default, constrain access with `private`, and prefer dependency injection via initializer parameters. Adopt `camelCase` for methods and properties, `PascalCase` for types, and group helpers with `// MARK:` separators when files grow.

## Testing Guidelines
All targets use XCTest. Name methods `test_<scenario>_<expectedOutcome>()` to mirror existing suites. When adding coverage, favor fakes over full subsystems and assert behavior rather than call counts. Update the relevant `.xctestplan` to include new test bundles and rerun the iOS test plan locally before pushing. End-to-end tests should only target boundary integrations (HTTP contracts, cache expiry) to keep runs fast.

## Commit & Pull Request Guidelines
Write concise, imperative commit subjects (`Fix remote feed retry policy`) and scope each commit to a single concern. Include a short body when clarifying context or trade-offs. Pull requests need: summary of the change, validation commands executed, linked issues or Trello cards, and simulator screenshots for visible UI updates. Request review once CI on both test plans is green.
