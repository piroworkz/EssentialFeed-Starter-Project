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
            throw RemoteFeedLoader.Error.invalidData
        }
        return items
    }
}
