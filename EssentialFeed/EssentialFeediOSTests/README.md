# EssentialFeediOSTests

## Purpose
EssentialFeediOSTests exercises the UIKit layer through snapshot-driven coverage, ensuring the feed screen renders consistently across states.

## Architecture
The suite instantiates storyboard scenes in isolation, driving controllers with lightweight stubs that mimic presenter output. Snapshot helpers capture reference images stored in `snapshots/` and fail when regressions appear. Additional utilities extend `UIImage` and `UIViewController` to simplify snapshot setup and comparison.

## Key files
- `FeedSnapshotTests.swift`: coverage for empty, populated, error, and failed image states.
- `Utils/`: shared helpers (`XCTestCase+Snapshot`, `UIViewController+Snapshot`, `UIImage+TestHelpers`).
- `snapshots/`: baseline PNGs for light and dark appearances.

## Workflow
Run `xcodebuild -scheme EssentialFeed -only-testing:EssentialFeediOSTests test` to validate snapshots. When intentional UI changes occur, regenerate reference images and commit them with the code so reviewers can track visual differences.
