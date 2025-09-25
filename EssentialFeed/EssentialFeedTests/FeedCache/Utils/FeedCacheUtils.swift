//
//  FeedCacheUtils.swift
//  EssentialFeedTests
//
//  Created by David Luna on 25/09/25.
//

import Foundation
import EssentialFeed

func uniqueImageFeed() -> (domain: [FeedImage], local: [LocalFeedImage]) {
    let domain = [uniqueImage(), uniqueImage()]
    let local = domain.map { $0.toLocal() }
    return (domain, local)
}

func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "Description", location: "location", imageURL: anyURL())
}

extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
