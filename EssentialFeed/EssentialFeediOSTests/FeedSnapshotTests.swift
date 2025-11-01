//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by David Luna on 01/11/25.
//

import XCTest
import EssentialFeediOS

final class FeedSnapshotTests: XCTestCase {
    
    func test_emptyFeed() {
        let sut = buildSUT()
        
        sut.display(emptyFeed())
        
        record(snapshot: sut.snapthot(), named: "EMPTY_FEED")
    }
}

extension FeedSnapshotTests {
    private func buildSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        controller.loadViewIfNeeded()
        return controller
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        return []
    }
    
    private func record(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate png data from snapshot", file: file, line: line)
            return
        }
        
        let snapshotURL = URL(fileURLWithPath: "\(file)")
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
        
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try snapshotData.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to create snapshots directory: \(error)", file: file, line: line)
        }
            
    }
}

extension UIViewController {
    func snapthot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        return renderer.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}
