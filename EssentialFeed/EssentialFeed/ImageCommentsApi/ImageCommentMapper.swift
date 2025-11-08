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
        
        guard response.validateStatusCode(byRange: 200...299), let items = try? decoder.decode(RemoteResponse.self, from: data).imageComments else {
            return .failure(RemoteImageCommentsLoader.Error.invalidData)
        }
        return .success(items)
    }
}
