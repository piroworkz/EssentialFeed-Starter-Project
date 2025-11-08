//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by David Luna on 18/09/25.
//

import Foundation

public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

public extension RemoteFeedLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: FeedImageMapper.map)
    }
}
