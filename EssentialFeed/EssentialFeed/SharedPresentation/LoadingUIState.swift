//
//  FeedLoadingViewState.swift
//  EssentialFeed
//
//  Created by David Luna on 26/10/25.
//

import Foundation

public struct LoadingUIState {
    public let isLoading: Bool
    
    public static var loading: LoadingUIState {
        return LoadingUIState(isLoading: true)
    }
    
    public static var notLoading: LoadingUIState {
        return LoadingUIState(isLoading: false)
    }
}
