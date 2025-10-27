//
//  FeedErrorViewState.swift
//  EssentialFeed
//
//  Created by David Luna on 26/10/25.
//


public struct FeedErrorViewState {
    public let message: String?
    
    static var noError: FeedErrorViewState {
        return FeedErrorViewState(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewState {
        return FeedErrorViewState(message: message)
    }
}
