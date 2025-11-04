//
//  RemoteFeedLoader 2.swift
//  EssentialFeed
//
//  Created by David Luna on 03/11/25.
//
import Foundation

public final class RemoteImageCommentsLoader {
    private let client: HTTPClient
    private let url: URL
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public typealias Result = Swift.Result<[ImageComment], Error>
    
    public enum Error: Swift.Error {
        case connection
        case invalidData
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            completion(result.toImageComment())
        }
    }

}
