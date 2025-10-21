//
//  FeedErrorViewState.swift
//  EssentialFeed
//
//  Created by David Luna on 21/10/25.
//


struct FeedErrorViewState {
    let message: String?
    
    static var noError: FeedErrorViewState {
        return FeedErrorViewState(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewState {
        return FeedErrorViewState(message: message)
    }
}
