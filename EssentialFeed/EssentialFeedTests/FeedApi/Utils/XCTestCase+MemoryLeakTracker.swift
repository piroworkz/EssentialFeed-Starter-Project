//
//  XCTestCase+MemoryLeakTracker.swift
//  EssentialFeedTests
//
//  Created by David Luna on 21/09/25.
//

import XCTest

extension XCTestCase {
    func trackMemoryLeak(for instance: AnyObject,  file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance of SUT must be deallocated after each test", file: file, line: line)
        }
    }
}
