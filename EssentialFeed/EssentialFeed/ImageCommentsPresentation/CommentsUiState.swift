//
//  ImageCommentsUiState.swift
//  EssentialFeed
//
//  Created by David Luna on 10/11/25.
//
import Foundation

public struct CommentsUiState: Equatable {
    public let comments: [CommentUiState]
    
    public init(comments: [CommentUiState]) {
        self.comments = comments
    }
}
