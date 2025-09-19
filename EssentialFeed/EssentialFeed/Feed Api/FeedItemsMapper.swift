//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by David Luna on 19/09/25.
//

import Foundation


internal class FeedItemsMapper {
    
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
    }
    
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
    }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        let successCode: Int = 200
        guard response.statusCode == successCode else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return try JSONDecoder().decode(Root.self, from: data).feedItems
    }
    
}
