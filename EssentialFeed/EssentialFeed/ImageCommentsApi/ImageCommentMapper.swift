//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by David Luna on 19/09/25.
//

import Foundation

public class ImageCommentMapper {
    
    public static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [ImageComment] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard response.validateStatusCode(in: 200...299), let items = try? decoder.decode(RemoteResponse.self, from: data).imageComments else {
            throw Error.invalidData
        }
        return items
    }
    
    private struct RemoteResponse: Decodable {
        let items: [RemoteImageComment]
        
        var imageComments: [ImageComment] {
            items.map { item in
                ImageComment(id: item.id, message: item.message, createdAt: item.created_at, username: item.author.username)
            }
        }
    }
    
    private struct RemoteImageComment: Decodable {
        let id: UUID
        let message: String
        let created_at: Date
        let author: RemoteAuthor
    }

    private struct RemoteAuthor: Decodable {
        let username: String
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
}

private extension HTTPURLResponse {
    func validateStatusCode(in validStatusCodes: ClosedRange<Int>) -> Bool {
        return validStatusCodes.contains(statusCode)
    }
}
