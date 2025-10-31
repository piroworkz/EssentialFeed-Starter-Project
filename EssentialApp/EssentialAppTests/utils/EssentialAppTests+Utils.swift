//
//  EssentialAppTests+Utils.swift
//  EssentialAppTests
//
//  Created by David Luna on 31/10/25.
//

import XCTest

extension XCTestCase {
    
    func trackMemoryLeak(for instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance of SUT must be deallocated after each test", file: file, line: line)
        }
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
}
