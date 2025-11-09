# EssentialFeedCacheIntegrationTests

## Purpose
This bundle exercises the Core Data-backed cache through real integrations to ensure feed and image persistence behaves correctly across app launches.

## Architecture
Tests construct `LocalFeedLoader` and `LocalFeedImageDataLoader` instances pointing to a temporary store URL. Real `CoreDataFeedStore` objects read and write data so scenarios validate disk persistence, cross-instance coherence, and cache expiration logic.

## Key scenarios
- Loading from an empty store returns an empty feed.
- Separate loader instances can save and later read feed entries and image data.
- Cache validation deletes stale feeds while preserving recently saved content.

## Workflow
Each test cleans the temporary store in `setUp`/`tearDown` to ensure isolation. Run the suite with `xcodebuild -scheme EssentialFeed -only-testing:EssentialFeedCacheIntegrationTests test` when modifying Core Data models or cache policies. Keep new tests focused on observable behaviour rather than private implementation details.
