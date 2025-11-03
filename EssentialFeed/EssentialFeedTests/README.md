# EssentialFeedTests

## Purpose
EssentialFeedTests verifies the behaviour of the feed domain module. It covers loading, caching, cache validation, and presentation contracts to ensure the core framework remains stable.

## Architecture
Suites are organised by feature to mirror the production layout. Each test builds the system under test with minimal collaborators supplied by spies and stubs from `Utils`. Memory leak tracking guards against retain cycles, and helper factories create deterministic feed payloads for assertions.

## Key directories
- `FeedApi`: remote loader specs asserting HTTP interactions and error handling.
- `FeedCache`: use-case tests for Core Data-backed caching and cache validation rules.
- `FeedPresentation`: presenter behaviour and view model formatting contracts.
- `Utils`: shared spies such as `HTTPClientSpy`, feed factories, and data helpers.

## Running
Execute `xcodebuild -scheme EssentialFeed -only-testing:EssentialFeedTests test` from the repository root to run this bundle. Align new tests with the production folder you cover and keep method names in the `test_<scenario>_<expectedResult>()` style for clarity.
