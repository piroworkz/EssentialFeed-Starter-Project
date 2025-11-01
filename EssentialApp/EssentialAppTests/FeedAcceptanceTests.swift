//
//  EssentialAppUIAcceptanceTests.swift
//  EssentialAppUIAcceptanceTests
//
//  Created by David Luna on 31/10/25.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
import UIKit
@testable import EssentialApp

final class FeedAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let feed = launchScene(httpClient: .online(response), store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(feed.renderedImageData(at: 0), makeImageData())
        XCTAssertEqual(feed.renderedImageData(at: 1), makeImageData())
    }

    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let sharedStore = InMemoryFeedStore.empty
        let onlineFeed = launchScene(httpClient: .online(response), store: sharedStore)
        onlineFeed.simulateFeedImageViewVisible(at: 0)
        onlineFeed.simulateFeedImageViewVisible(at: 1)
        
        let offlineFeed = launchScene(httpClient: .offline, store: sharedStore)
        
        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(offlineFeed.renderedImageData(at: 0), makeImageData())
        XCTAssertEqual(offlineFeed.renderedImageData(at: 1), makeImageData())
    }

    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let feed = launchScene(httpClient: .offline, store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 0)
    }
    
    func test_onEnteringBackground_deletesExpiredFeedCache() {
        let store = InMemoryFeedStore.withExpiredCache
        
        enterBackground(with: store)
        
        XCTAssertNil(store.feedCache, "Expected expired cache to be deleted upon entering background")
    }
    
    func test_onEnteringBackground_keepsNonExpiredFeedCache() {
        let store = InMemoryFeedStore.withNonExpiredCache
        
        enterBackground(with: store)
        
        XCTAssertNotNil(store.feedCache, "Expected non-expired cache to be kept upon entering background")
    }
}

extension FeedAcceptanceTests {
    private func launchScene(httpClient: HTTPClientStub = .offline, store: InMemoryFeedStore = .empty) -> FeedViewController {
        let sut = SceneDelegate(httpClient: httpClient, localStore: store)
        sut.window = UIWindow()
        sut.configureWindow()
        let navController = sut.window?.rootViewController as! UINavigationController
        let feedController = navController.topViewController as! FeedViewController
        feedController.simulateViewAppearing()
        return feedController
    }
    
    private func enterBackground(with store: InMemoryFeedStore) {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, localStore: store)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }
    
    private class HTTPClientStub: HTTPClient {
            private class Task: HTTPClientTask {
                func cancel() {}
            }
            
            private let stub: (URL) -> HTTPClient.Result
                    
            init(stub: @escaping (URL) -> HTTPClient.Result) {
                self.stub = stub
            }

            func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
                completion(stub(url))
                return Task()
            }
            
            static var offline: HTTPClientStub {
                HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
            }
            
            static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
                HTTPClientStub { url in .success(stub(url)) }
            }
        }
        
        private class InMemoryFeedStore: FeedStore, FeedImageDataStore {
            private(set) var feedCache: CachedFeed?
            private var feedImageDataCache: [URL: Data] = [:]
            
            private init(feedCache: CachedFeed? = nil) {
                self.feedCache = feedCache
            }
            
            func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
                feedCache = nil
                completion(.success(()))
            }
            
            func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
                feedCache = CachedFeed(feed: feed, timestamp: timestamp)
                completion(.success(()))
            }
            
            func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
                completion(.success(feedCache))
            }
            
            func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
                feedImageDataCache[url] = data
                completion(.success(()))
            }
            
            func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
                completion(.success(feedImageDataCache[url]))
            }
            
            static var empty: InMemoryFeedStore {
                InMemoryFeedStore()
            }
            
            static var withExpiredCache: InMemoryFeedStore {
                InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date.distantPast))
            }
            
            static var withNonExpiredCache: InMemoryFeedStore {
                InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date()))
            }
        }

        private func response(for url: URL) -> (Data, HTTPURLResponse) {
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (makeData(for: url), response)
        }
        
        private func makeData(for url: URL) -> Data {
            switch url.absoluteString {
            case "http://image.com":
                return makeImageData()
                
            default:
                return makeFeedData()
            }
        }
        
        private func makeImageData() -> Data {
            return UIImage.make(withColor: .red).pngData()!
        }
        
        private func makeFeedData() -> Data {
            return try! JSONSerialization.data(withJSONObject: ["items": [
                ["id": UUID().uuidString, "image": "http://image.com"],
                ["id": UUID().uuidString, "image": "http://image.com"]
            ]])
        }
}

