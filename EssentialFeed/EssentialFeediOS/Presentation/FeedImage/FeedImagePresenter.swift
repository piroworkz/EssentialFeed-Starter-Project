//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by David Luna on 16/10/25.
//

import Foundation
import EssentialFeed

protocol FeedImageView {
    associatedtype Image
    func display(_ state: FeedImageState<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageMapper: (Data) -> Image?
    private struct InvalidIMageDataError: Error {}
    
    private var currentState: FeedImageState<Image> = FeedImageState()
    
    init(view: View, imageMapper: @escaping (Data) -> Image?) {
        self.view = view
        self.imageMapper = imageMapper
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        let state = currentState.update(
            description: model.description,
            location: model.location,
            isLoading: true,
        )
        
        view.display(state)
    }
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        guard let image = imageMapper(data) else { return
            didFinishLoadingImageData(with: InvalidIMageDataError(), for: model)
        }
        
        view.display(
            currentState.update(
                image: image,
                isLoading: false
            )
        )
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(
            currentState.update(
                image: nil,
                isLoading: false,
                shouldRetry: true
            )
        )
    }
}
