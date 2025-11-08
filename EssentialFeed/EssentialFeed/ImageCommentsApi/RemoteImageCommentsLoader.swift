//
//  RemoteFeedLoader 2.swift
//  EssentialFeed
//
//  Created by David Luna on 03/11/25.
//
import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: ImageCommentMapper.map)
    }
}
