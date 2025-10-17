//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by David Luna on 16/10/25.
//

import Foundation
import EssentialFeed

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private let mapImage: (Data) -> Image?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader, mapImage: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.mapImage = mapImage
    }
    
    var description: String? {
        return model.description
    }
    
    var location: String?  {
        return model.location
    }
    
    var hasLocation: Bool {
        return location != nil
    }
    
    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = imageLoader.loadImageData(from: model.imageURL) { [weak self] result in
            self?.onResult(result)
        }
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
    
    private func onResult(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(mapImage) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }
}
