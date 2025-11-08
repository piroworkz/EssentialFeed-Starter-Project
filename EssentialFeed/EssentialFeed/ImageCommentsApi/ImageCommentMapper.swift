//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by David Luna on 19/09/25.
//

import Foundation

class ImageCommentMapper {
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [ImageComment] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard response.validateStatusCode(byRange: 200...299), let items = try? decoder.decode(RemoteResponse.self, from: data).imageComments else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }
        return items
    }
}
