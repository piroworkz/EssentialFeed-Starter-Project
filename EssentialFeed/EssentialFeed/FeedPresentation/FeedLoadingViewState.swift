//
//  FeedLoadingViewState.swift
//  EssentialFeed
//
//  Created by David Luna on 26/10/25.
//

import Foundation

public struct FeedLoadingViewState {
    public let isLoading: Bool
    
    public static var loading: FeedLoadingViewState {
        return FeedLoadingViewState(isLoading: true)
    }
    
    public static var notLoading: FeedLoadingViewState {
        return FeedLoadingViewState(isLoading: false)
    }
}
