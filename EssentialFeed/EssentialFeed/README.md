# EssentialFeed

## Purpose
EssentialFeed groups the feed domain rules and the infrastructure adapters that support them. It exposes the boundary protocols `FeedLoader` and `FeedImageDataLoader` consumed by higher layers while keeping storage and HTTP details hidden behind abstractions.

## Architecture
The module follows a use-case centric, layered design. Each use case (load, cache, validate) operates on value types in `Feed Feature` and collaborates through dependency inversion. Remote adapters under `Feed Api` translate HTTP responses into domain models, while `FeedCache` offers Core Data-backed implementations of caching policies. Presentation models in `FeedPresentation` keep UI modules agnostic by converting domain outcomes into view models.

## Key directories
- `Feed Feature`: core models (`FeedImage`), boundary protocols, and factories.
- `Feed Api`: remote loaders, mappers, and the concrete `URLSessionHTTPClient`.
- `FeedCache`: Core Data store, cache expiration policies, and image data storage.
- `FeedImageLoader`: shared infrastructure for image data retrieval.
- `FeedPresentation`: presenters, view models, and delegate abstractions independent of UIKit.

## Integration
The framework has no third-party dependencies and compiles as a static target via the `EssentialFeed` scheme. Add new behaviours by introducing protocol methods first, then providing concrete adapters inside the appropriate folder so tests can remain isolated from infrastructure.
