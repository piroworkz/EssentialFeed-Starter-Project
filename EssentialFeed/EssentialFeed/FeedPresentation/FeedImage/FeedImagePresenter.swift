//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by David Luna on 26/10/25.
//

import Foundation

public final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    
    private let view: View
    private let imageMapper: (Data) -> Image?
    
    private struct InvalidImageDataError: Error {}
    
   public init(view: View, imageMapper: @escaping (Data) -> Image?) {
        self.view = view
        self.imageMapper = imageMapper
    }
    
    public func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageState(description: model.description, location: model.location, image: nil, isLoading: true, shouldRetry: false))
    }
    
    public func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        guard let image = imageMapper(data) else {
            didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
            return
        }
        view.display(FeedImageState(description: model.description, location: model.location, image: image, isLoading: false, shouldRetry: false))
    }
    
    public func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(FeedImageState(description: model.description, location: model.location, image: nil, isLoading: false, shouldRetry: true))
    }
}
