//
//  Item.swift
//  EssentialFeed
//
//  Created by David Luna on 08/11/25.
//
import Foundation

struct RemoteFeedImage: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}

extension RemoteResponse where T == [RemoteFeedImage] {
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
