//
//  ToLocalStorage.swift
//  EssentialFeed
//
//  Created by David Luna on 24/09/25.
//

import Foundation

extension FeedImage {
    public func toLocal() -> LocalFeedImage {
        return LocalFeedImage(id: id, description: description, location: location, imageURL: imageURL)
    }
}
