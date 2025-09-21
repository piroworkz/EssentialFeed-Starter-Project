//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 19/09/25.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void){
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_performsGETRequestWithURL() {
        URLProtocolStub.startIntercepting()
        
        let expectedURL = URL(string: "htts://example.com")!
        let expectation = expectation(description: "Wait for completion")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, expectedURL)
            XCTAssertEqual(request.httpMethod, "GET")
            expectation.fulfill()
        }
        
        URLSessionHTTPClient().get(from: expectedURL) { _ in }
        
        wait(for: [expectation], timeout: 1.0)
        URLProtocolStub.stopIntercepting()
    }
    
    func test_getFromURL_failsONRequestError() {
        URLProtocolStub.startIntercepting()
        
        let url = URL(string: "htts://example.com")!
        let expected = NSError(domain: "test error", code: 1)
        URLProtocolStub.stub(data: nil, response: nil, error: expected)
        
        let sut = URLSessionHTTPClient()
        let expectation = expectation(description: "Wait for completion")
        
        sut.get(from: url) { actual in
            switch actual {
            case let .failure(actualError as NSError):
                XCTAssertEqual(actualError.domain, expected.domain)
                XCTAssertEqual(actualError.code, expected.code)
            default:
                XCTFail("Expected \(expected) but got \(actual) instead")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        URLProtocolStub.stopIntercepting()
    }
}

extension URLSessionHTTPClientTests {
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub{
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?,  error: Error?) {
            stub = Stub(
                data: data,
                response: response,
                error: error
            )
        }
        
        static func observeRequests(_ observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startIntercepting() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopIntercepting() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
        
    }
}
