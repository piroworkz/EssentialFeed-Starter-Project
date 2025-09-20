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
    
    init(session: URLSession) {
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
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "https://httpbin.org/get")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsONRequestError() {
        let url = URL(string: "https://httpbin.org/get")!
        let expected = NSError(domain: "test error", code: 1)
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, error: expected)
        let sut = URLSessionHTTPClient(session: session)
        let expectation = expectation(description: "Wait for completion")
        
        sut.get(from: url) { actual in
            switch actual {
            case let .failure(actualError as NSError):
                XCTAssertEqual(actualError, expected)
            default:
                XCTFail("Expected \(expected) but got \(actual) instead")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

extension URLSessionHTTPClientTests {
    
    private class URLSessionSpy: URLSession {
        private var stubs = [URL: Stub]()
        
        private struct Stub{
            let task: URLSessionDataTask
            let error: Error?
        }
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("No stub for index \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
        
        func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        private class FakeURLSessionDataTask: URLSessionDataTask {
            override func resume() {}
        }
        
    }
    
    class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }
}
