//
//  UiImageComment.swift
//  EssentialFeed
//
//  Created by David Luna on 10/11/25.
//
import Foundation

public struct Comment: Equatable {
    public let message: String
    public let date: String
    public let username: String
    
    public init(message: String, date: String, username: String) {
        self.message = message
        self.date = date
        self.username = username
    }
}
