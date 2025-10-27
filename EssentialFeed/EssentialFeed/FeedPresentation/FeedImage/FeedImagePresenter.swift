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
    
    private var currentState: FeedImageState<Image> = FeedImageState()
    private struct InvalidImageDataError: Error {}
    
   public init(view: View, imageMapper: @escaping (Data) -> Image?) {
        self.view = view
        self.imageMapper = imageMapper
    }
    
    public func didStartLoadingImageData(for model: FeedImage) {
        let state = currentState.update(
            description: model.description,
            location: model.location,
            isLoading: true,
        )
        view.display(state)
    }
    
    public func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        guard let image = imageMapper(data) else { return
            didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(
            currentState.update(
                image: image,
                isLoading: false
            )
        )
    }
    
    public func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(
            currentState.update(
                image: nil,
                isLoading: false,
                shouldRetry: true
            )
        )
    }
}
