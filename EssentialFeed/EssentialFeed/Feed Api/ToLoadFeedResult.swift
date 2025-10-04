//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by David Luna on 19/09/25.
//

import Foundation

extension HTTPClient.Result {
    
    func toLoadFeedResult() -> RemoteFeedLoader.Result {
        switch self {
        case let .success((data, response)):
            return map(data, response)
        case .failure(_):
            return RemoteFeedLoader.Result.failure(RemoteFeedLoader.Error.connection)
        }
    }
    
    private func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        let successCode: Int = 200
        guard response.statusCode == successCode, let items = try? JSONDecoder().decode(Root.self, from: data).feedItems  else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(items)
    }
    
    private struct Root: Decodable {
        private let items: [Item]
        
        var feedItems: [FeedImage] {
            items.map { item in
                FeedImage(
                    id: item.id,
                    description: item.description,
                    location: item.location,
                    imageURL: item.image
                )
            }
        }
        
        private struct Item: Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
        }
    }
}

