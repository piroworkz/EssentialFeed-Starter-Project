# Prototype

## Purpose
The Prototype target is a lightweight sandbox used to iterate quickly on feed UI ideas without composing the full production stack. It renders hard-coded feed data so designers and developers can experiment with layouts and transitions in isolation.

## Architecture
The storyboard in `Base.lproj` hosts a single `FeedViewController` driven by view models from `FeedImageViewModel+PrototypeData.swift`. Custom cells (`FeedImageCell.swift`) and adapters mimic the production appearance while omitting networking and persistence. Assets in `Assets.xcassets` provide sample images for the gallery.

## Key files
- `FeedViewController.swift`: table view controller rendering the prototype feed.
- `FeedImageCell.swift`: cell showcasing layout, selection, and loading states.
- `FeedImageViewModel+PrototypeData.swift`: static fixtures used during prototyping.

## Usage
Open `Prototype.xcodeproj` and run the `Prototype` scheme to preview the experience on a simulator. When experimenting with new UI patterns, add temporary helpers here before porting refined solutions into `EssentialFeediOS`.
