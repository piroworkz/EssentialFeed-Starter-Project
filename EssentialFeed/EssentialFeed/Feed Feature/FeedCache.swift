//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by David Luna on 31/10/25.
//
import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
