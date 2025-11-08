//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by David Luna on 19/09/25.
//

import Foundation

extension HTTPClient.Result {
    
    func toFeedImage() -> RemoteFeedLoader.Result {
        switch self {
        case let .success((data, response)):
            guard response.isOK, let items = try? JSONDecoder().decode(RemoteResponse.self, from: data).feedItems  else {
                return .failure(RemoteFeedLoader.Error.invalidData)
            }
            return .success(items)
        case .failure(_):
            return RemoteFeedLoader.Result.failure(RemoteFeedLoader.Error.connection)
        }
    }
    
    
}

extension HTTPURLResponse {
    
    var isOK: Bool {
        return statusCode == 200
    }
    
    func validateStatusCode(byRange validStatusCodes: ClosedRange<Int>) -> Bool {
        return validStatusCodes.contains(statusCode)
    }
    
}
