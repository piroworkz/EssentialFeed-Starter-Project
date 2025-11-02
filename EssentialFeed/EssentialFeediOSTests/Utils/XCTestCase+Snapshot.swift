//
//  XCTestCase+Snapshot.swift
//  EssentialFeediOSTests
//
//  Created by David Luna on 01/11/25.
//

import XCTest

extension XCTestCase {
    func assert(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotData = buildSnapshotData(for: snapshot, file: file, line: line)
        let snapshotURL = buildSnapshotURL(named: name, file: file)
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Did you forget to use the 'record' method to store snapshot before testing?", file: file, line: line)
            return
        }
        
        if snapshotData != storedSnapshotData {
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(snapshotURL.lastPathComponent)
            try? snapshotData?.write(to: temporarySnapshotURL)
            XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
        }
    }
    
    func record(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotData = buildSnapshotData(for: snapshot, file: file, line: line)
        let snapshotURL = buildSnapshotURL(named: name, file: file)
        
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try snapshotData?.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to create snapshots directory: \(error)", file: file, line: line)
        }
    }
    
    private func buildSnapshotURL(named name: String, file: StaticString = #filePath) -> URL {
        return URL(fileURLWithPath: "\(file)")
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
    
    private func buildSnapshotData(for snapshot: UIImage, file: StaticString = #filePath, line: UInt = #line) -> Data? {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate png data from snapshot", file: file, line: line)
            return nil
        }
        return snapshotData
    }
}
