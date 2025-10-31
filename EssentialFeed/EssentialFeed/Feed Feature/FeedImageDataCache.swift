//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by David Luna on 31/10/25.
//
import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>
    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
