//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by David Luna on 26/09/25.
//

import Foundation

final class FeedCachePolicy {
    private init() {}
    
    private static let calendar = Calendar(identifier: .gregorian)
    
    static func isCacheValid(_ timestamp: Date, against date: Date) -> Bool {
        let maxAgeInDays: Int = 7
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
