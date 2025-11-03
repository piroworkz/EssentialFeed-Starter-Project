# EssentialFeediOS

## Purpose
EssentialFeediOS contains the UIKit implementation of the feed experience. It composes controllers, views, and adapters that drive the feed UI with data coming from the domain module.

## Architecture
The target applies the Composer + Adapter style. `FeedUIComposer` assembles the scene, wiring `FeedLoaderPresentationAdapter` and `FeedImageDataLoaderPresentationAdapter` to the `FeedViewController`. Adapters translate `EssentialFeed` presenters into UIKit updates, while `DispatchQueue+MainScheduler` guarantees UI work happens on the main thread. Combine pipelines are wrapped in helpers so the UI stays decoupled from reactive details.

## Structure
- `UI/Controllers`: `FeedViewController`, `FeedImageCellController`, adapters, and the composer.
- `UI/Views`: storyboard, table view cells, and supporting views like `ErrorView`.
- `UI/Views/Utils`: UIKit extensions for shimmering placeholders, animations, dequeuing, and snapshot helpers.
- `UI/Views/Feed.xcassets`: asset catalogs for images and icons used by the feed.

## Integration
This framework is linked by `EssentialApp`. Keep composition logic inside the composer to avoid leaking domain dependencies into controllers. When extending the UI, prefer new controller or view types under `UI` and expose them through the composer so automated tests and snapshots can reuse them.
