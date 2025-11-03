//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by David Luna on 19/09/25.
//

import Foundation

extension HTTPClient.Result {
    
    func toImageComment() -> RemoteImageCommentsLoader.Result {
        switch self {
        case let .success((data, response)):
            return map(data, response)
        case .failure(_):
            return RemoteImageCommentsLoader.Result.failure(RemoteImageCommentsLoader.Error.connection)
        }
    }
    
    private func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteImageCommentsLoader.Result {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard response.validateStatusCode(byRange: 200...299), let items = try? decoder.decode(Root.self, from: data).imageComments else {
            return .failure(RemoteImageCommentsLoader.Error.invalidData)
        }
        return .success(items)
    }
    
    private struct Root: Decodable {
        private let items: [Item]
        
        var imageComments: [ImageComment] {
            items.map { item in
                ImageComment(id: item.id, message: item.message, createdAt: item.created_at, username: item.author.username)
            }
        }
        
        private struct Item: Decodable {
            let id: UUID
            let message: String
            let created_at: Date
            let author: Author
        }
        
        private struct Author: Decodable {
            let username: String
        }
    }
}

