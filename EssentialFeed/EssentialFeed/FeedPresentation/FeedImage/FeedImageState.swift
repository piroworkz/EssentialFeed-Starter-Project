//
//  FeedImageState.swift
//  EssentialFeed
//
//  Created by David Luna on 26/10/25.
//

public struct FeedImageState{
    public let description: String?
    public let location: String?
    
    public var hasLocation: Bool {
        return location != nil
    }
}
