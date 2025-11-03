# EssentialAppUIAcceptanceTests

## Purpose
This bundle hosts UI acceptance scenarios that exercise the full app stack using launch arguments. It verifies the feed experience under different connectivity and cache setups from a black-box perspective.

## Architecture
Tests launch `XCUIApplication` with custom arguments such as `-connectivity online|offline` and `-reset` to toggle stubs defined inside the app target. Assertions rely on accessibility identifiers (`feed-image-cell`, `feed-image-view`) to inspect visible UI elements without depending on implementation details.

## Key scenarios
- Remote feed loads when connectivity is available.
- Cached feed is displayed when the device launches offline.
- Empty state appears when cache and connectivity are both unavailable.

## Usage
Run the suite with `xcodebuild -scheme EssentialApp -only-testing:EssentialAppUIAcceptanceTests test`. When introducing new acceptance flows, extend the `buildApp(connectivity:reset:)` helper so launch configuration stays centralized.
