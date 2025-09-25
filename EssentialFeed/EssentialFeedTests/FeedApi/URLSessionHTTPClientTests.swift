//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 19/09/25.
//

import XCTest
import EssentialFeed


class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_performsGETRequestWithURL() {
        let expectedURL = anyURL()
        let expectation = expectation(description: "Wait for completion")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, expectedURL)
            XCTAssertEqual(request.httpMethod, "GET")
            expectation.fulfill()
        }
        
        buildSUT().get(from: expectedURL) { _ in }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let expected = NSError(domain: "test error", code: 1)
        
        let actual = resultErrorFor(data: nil, response: nil, error: expected) as NSError?
        
        XCTAssertEqual(actual?.domain, expected.domain)
        XCTAssertEqual(actual?.code, expected.code)
    }
    
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromURL_succeedsOnHttpUrlResponseWithData() {
        let expectedData = anyData()
        let expectedResponse = anyHTTPURLResponse()
        
        let actual = resultValues(data: expectedData, response: expectedResponse, error: nil)
        
        XCTAssertEqual(actual?.data, expectedData)
        XCTAssertEqual(actual?.response.url, expectedResponse.url)
        XCTAssertEqual(actual?.response.statusCode, expectedResponse.statusCode)
    }
    
    func test_getFromURL_succeedsWithEmptyDataOnHttpUrlResponseWithNullData() {
        let expectedResponse = anyHTTPURLResponse()
        
        let actual = resultValues(data: nil, response: expectedResponse, error: nil)
        
        XCTAssertTrue(((actual?.data.isEmpty) != nil))
        XCTAssertEqual(actual?.response.url, expectedResponse.url)
        XCTAssertEqual(actual?.response.statusCode, expectedResponse.statusCode)
    }
    
}

extension URLSessionHTTPClientTests {
    
    override func setUp() {
        URLProtocolStub.startIntercepting()
    }
    
    override func tearDown() {
        URLProtocolStub.stopIntercepting()
    }
    
    private func buildSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackMemoryLeak(for: sut, file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?,  error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected any failure, but got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultValues(data: Data?, response: URLResponse?,  error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .success(data, response):
            return (data, response)
        default:
            XCTFail("Expected success, but got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(data: Data?, response: URLResponse?,  error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let expectation = expectation(description: "Wait for completion")
        
        var receivedResult: HTTPClientResult!
        buildSUT().get(from: anyURL()) { result in
            receivedResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        return receivedResult
    }
    
    private func nonHTTPURLResponse() -> URLResponse{
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return  HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
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
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let requestObserver = URLProtocolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }
            
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
