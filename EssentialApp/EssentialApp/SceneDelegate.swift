//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by David Luna on 30/10/25.
//
import UIKit
import CoreData
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let localStorageURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.sqlite")
    
    private lazy var httpClient: HTTPClient = {
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        return client
    }()
    
    private lazy var localStore: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(storeURL: localStorageURL)
    }()
    
    convenience init(httpClient: HTTPClient, localStore: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.localStore = localStore
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        configureWindow()
    }
    
    func configureWindow() {
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let client = buildClient()
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: client)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: client)
        
        let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(store: localStore)
        let feedLoaderDecorator = FeedLoaderCacheDecorator(decoratee: remoteFeedLoader, cache: localFeedLoader)
        let feedImageLoaderDecorator = FeedImageDataLoaderCacheDecorator(decoratee: remoteImageLoader, cache: localImageLoader)
        let feedLoader = FeedLoaderWithFallbackComposite(primary: feedLoaderDecorator, fallback: localFeedLoader)
        let feedImageLoader = FeedImageDataLoaderWithFallbackComposite(primary: localImageLoader, fallback: feedImageLoaderDecorator)
        let feedViewController = FeedUIComposer.feedComposedWith(feedLoader: feedLoader, imageLoader: feedImageLoader)
        window?.rootViewController = UINavigationController(rootViewController: feedViewController)
    }
    
    func buildClient() -> HTTPClient {
        return httpClient
    }
}

