//
//  ToLocalStorage.swift
//  EssentialFeed
//
//  Created by David Luna on 24/09/25.
//

import Foundation

extension FeedItem {
    public func toLocal() -> LocalFeedItem {
        return LocalFeedItem(id: id, description: description, location: location, imageURL: imageURL)
    }
}
