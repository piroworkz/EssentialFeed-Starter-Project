//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by David Luna on 30/10/25.
//
import UIKit
import CoreData
import Combine
import EssentialFeed

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
    
    private lazy var remoteFeedLoader: RemoteFeedLoader = {
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        return RemoteFeedLoader(url: url, client: httpClient)
    }()
    
    private lazy var remoteImageLoader: RemoteFeedImageDataLoader = RemoteFeedImageDataLoader(client: httpClient)
    private lazy var localImageLoader: LocalFeedImageDataLoader = LocalFeedImageDataLoader(store: localStore)

    convenience init(httpClient: HTTPClient, localStore: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.localStore = localStore
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
        let feedViewController = FeedUIComposer.feedComposedWith(feedLoader: buildRemoteFeedLoaderWithFallback, imageLoader: buildLocalImageLoaderWithFallback)
        window?.rootViewController = UINavigationController(rootViewController: feedViewController)
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    private func buildRemoteFeedLoaderWithFallback() -> FeedLoader.Publisher {
        return remoteFeedLoader
            .loadPublisher()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
    
    private func buildLocalImageLoaderWithFallback(url: URL) -> FeedImageDataLoader.Publisher {
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: { [weak self] in
                guard let self = self else {
                    return Empty<Data, Error>().eraseToAnyPublisher()
                }
                return self.remoteImageLoader
                    .loadImageDataPublisher(from: url)
                    .caching(to: self.localImageLoader, for: url)
            })
    }
}

extension RemoteLoader: FeedLoader where T == [FeedImage] {}

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: ImageCommentMapper.map)
    }
}


public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

public extension RemoteFeedLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: FeedImageMapper.map)
    }
}
