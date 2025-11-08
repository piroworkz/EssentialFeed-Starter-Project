//
//  Item.swift
//  EssentialFeed
//
//  Created by David Luna on 08/11/25.
//
import Foundation

struct RemoteImageComment: Decodable {
    let id: UUID
    let message: String
    let created_at: Date
    let author: RemoteAuthor
}

struct RemoteAuthor: Decodable {
    let username: String
}

extension RemoteResponse where T == [RemoteImageComment] {
    var imageComments: [ImageComment] {
        items.map { item in
            ImageComment(id: item.id, message: item.message, createdAt: item.created_at, username: item.author.username)
        }
    }
}
