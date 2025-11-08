//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by David Luna on 03/11/25.
//


import Foundation

public final class RemoteLoader<T> {
    public typealias Result = Swift.Result<T, Swift.Error>
    public typealias Mapper = (Data, HTTPURLResponse) throws -> T
    private let client: HTTPClient
    private let url: URL
    private let mapper: Mapper
    
    public init(url: URL, client: HTTPClient, mapper: @escaping Mapper) {
        self.client = client
        self.url = url
        self.mapper = mapper
    }
    
    public enum Error: Swift.Error {
        case connection
        case invalidData
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success((data, response)):
                completion(self.map(data: data, response: response))
            case .failure:
                completion(.failure(Error.connection))
            }
        }
    }
    
    private func map(data: Data, response: HTTPURLResponse) -> Result {
        do {
            return .success(try mapper(data, response))
        } catch {
            return .failure(Error.invalidData)
        }
    }
    
}
