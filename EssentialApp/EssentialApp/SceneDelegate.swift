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
    
    private lazy var httpClient: HTTPClient = {
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        return client
    }()
    
    private lazy var localStore: FeedStore & FeedImageDataStore = {
        let localStorageURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.sqlite")
        return try! CoreDataFeedStore(storeURL: localStorageURL)
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: localStore, currentDate: Date.init)
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
        
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: httpClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageLoader = LocalFeedImageDataLoader(store: localStore)
        let feedLoaderDecorator = FeedLoaderCacheDecorator(decoratee: remoteFeedLoader, cache: localFeedLoader)
        let feedImageLoaderDecorator = FeedImageDataLoaderCacheDecorator(decoratee: remoteImageLoader, cache: localImageLoader)
        let feedLoader = FeedLoaderWithFallbackComposite(primary: feedLoaderDecorator, fallback: localFeedLoader)
        let feedImageLoader = FeedImageDataLoaderWithFallbackComposite(primary: localImageLoader, fallback: feedImageLoaderDecorator)
        let feedViewController = FeedUIComposer.feedComposedWith(feedLoader: feedLoader, imageLoader: feedImageLoader)
        window?.rootViewController = UINavigationController(rootViewController: feedViewController)
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
}
