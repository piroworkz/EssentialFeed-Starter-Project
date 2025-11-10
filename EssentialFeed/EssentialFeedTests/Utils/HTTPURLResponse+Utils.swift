//
//  File.swift
//  EssentialFeed
//
//  Created by David Luna on 08/11/25.
//
import Foundation

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: URL(string: "https://example.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
