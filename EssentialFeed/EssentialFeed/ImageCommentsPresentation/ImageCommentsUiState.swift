//
//  ImageCommentsUiState.swift
//  EssentialFeed
//
//  Created by David Luna on 10/11/25.
//
import Foundation

public struct ImageCommentsUiState: Equatable {
    public let comments: [Comment]
    
    public init(comments: [Comment]) {
        self.comments = comments
    }
}
