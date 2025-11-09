//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by David Luna on 19/09/25.
//

import Foundation

public class FeedImageMapper {
    public static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
        guard response.isOK, let items = try? JSONDecoder().decode(RemoteResponse.self, from: data).feedItems  else {
            throw Error.invalidData
        }
        return items
    }
    
    private struct RemoteResponse: Decodable {
        let items: [RemoteFeedImage]
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
    }
    
    private struct RemoteFeedImage: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
    }
    
    
    public enum Error: Swift.Error {
        case invalidData
    }
}

private extension HTTPURLResponse {
    var isOK: Bool {
        return statusCode == 200
    }
}
