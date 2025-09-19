//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by David Luna on 18/09/25.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public enum Error: Swift.Error {
        case connection
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, _):
                if let root = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(root.feedItems))
                } else {
                    completion(.failure(.invalidData))
                }
                
            case .failure(_):
                completion(.failure(.connection))
            }
        }
    }
}

private struct Root: Decodable {
    private let items: [Item]
    
    var feedItems: [FeedItem] {
        items.map { item in
            FeedItem(
                id: item.id,
                description: item.description,
                location: item.location,
                imageURL: item.image
            )
        }
    }
    
    struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
    }
}
