//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by David Luna on 18/09/25.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void)
}

public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public enum Error: Swift.Error {
        case connection
        case invalidData
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { _, response  in
            if response != nil {
                completion(.invalidData)
            } else {
                completion(.connection)
            }
        }
    }
}
