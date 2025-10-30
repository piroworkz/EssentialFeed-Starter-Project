//
//  FeedImageState.swift
//  EssentialFeed
//
//  Created by David Luna on 26/10/25.
//

public struct FeedImageState<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        return location != nil
    }
}
