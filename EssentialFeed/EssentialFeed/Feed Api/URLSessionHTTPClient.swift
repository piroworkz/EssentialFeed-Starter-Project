//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by David Luna on 21/09/25.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct IllegalStateException: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void){
        session.dataTask(with: url) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw IllegalStateException()
                }
            })
        }.resume()
    }
}
