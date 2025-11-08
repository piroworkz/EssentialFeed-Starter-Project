//
//  RemoteResponse.swift
//  EssentialFeed
//
//  Created by David Luna on 08/11/25.
//

struct RemoteResponse<T: Decodable>: Decodable {
    let items: T
}
