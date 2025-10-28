//
//  SharedTestUtils.swift
//  EssentialFeedTests
//
//  Created by David Luna on 25/09/25.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "https://example.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any", code: 0)
}

func anyData() -> Data {
    return Data("any data".utf8)
}
