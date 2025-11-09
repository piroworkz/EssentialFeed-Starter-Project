//
//  FeedErrorViewState.swift
//  EssentialFeed
//
//  Created by David Luna on 26/10/25.
//


public struct ErrorMessageUIState {
    public let message: String?
    
    static var noError: ErrorMessageUIState {
        return ErrorMessageUIState(message: nil)
    }
    
    static func error(message: String) -> ErrorMessageUIState {
        return ErrorMessageUIState(message: message)
    }
}
