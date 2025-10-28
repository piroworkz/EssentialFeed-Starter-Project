//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by David Luna on 19/09/25.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    @discardableResult
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}

public protocol HTTPClientTask {
    func cancel()
}
