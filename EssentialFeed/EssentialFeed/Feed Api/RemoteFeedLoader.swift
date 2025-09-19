//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by David Luna on 18/09/25.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public typealias Result = LoadFeedResult
    
    public enum Error: Swift.Error {
        case connection
        case invalidData
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(data, response):
                completion(FeedItemsMapper.map(data, response))
            case .failure(_):
                completion(.failure(RemoteFeedLoader.Error.connection))
            }
        }
    }

}
