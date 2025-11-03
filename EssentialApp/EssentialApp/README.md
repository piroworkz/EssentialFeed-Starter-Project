# EssentialApp

## Purpose
EssentialApp is the iOS host application that wires the domain and UI frameworks into a runnable product. It owns the app lifecycle, dependency composition, and navigation.

## Architecture
`SceneDelegate` bootstraps the main window and uses `FeedUIComposer` to assemble the feed scene. Presentation adapters bridge `FeedLoader` and `FeedImageDataLoader` protocols from `EssentialFeed` to UIKit controllers. Helpers such as `WeakReference`, `Combine+Utils`, and `DispatchQueue+MainScheduler` enforce memory safety and main-thread delivery for presenter callbacks.

## Key files
- `FeedUIComposer.swift`: composition root that injects dependencies and builds navigation controllers.
- `FeedLoaderPresentationAdapter.swift` & `FeedImageDataLoaderPresentationAdapter.swift`: translate async state into presenter messages.
- `FeedViewAdapter.swift`: applies view models to table view cells and propagates selection.
- `SceneDelegate.swift`: coordinates window creation and background lifecycle hooks.

## Integration
Storyboard resources live under `Base.lproj`, while shared branding sits in `Assets.xcassets`. When adding new flows, prefer creating dedicated composers and keep domain modules injected through protocol abstractions so tests can substitute in-memory implementations.
