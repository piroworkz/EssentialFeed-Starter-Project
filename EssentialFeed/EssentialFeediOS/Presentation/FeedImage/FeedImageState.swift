//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by David Luna on 16/10/25.
//

import Foundation
import EssentialFeed

struct FeedImageState<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    init(
        description: String? = nil,
        location: String? = nil,
        image: Image? = nil,
        isLoading: Bool = false,
        shouldRetry: Bool = false
    ) {
        self.description = description
        self.location = location
        self.image = image
        self.isLoading = isLoading
        self.shouldRetry = shouldRetry
    }
}


extension FeedImageState {
    
    func update(
        description: String?? = nil,
        location: String?? = nil,
        image: Image?? = nil,
        isLoading: Bool? = nil,
        shouldRetry: Bool? = nil
    ) -> FeedImageState<Image> {
        FeedImageState(
            description: description ?? self.description,
            location: location ?? self.location,
            image: image ?? self.image,
            isLoading: isLoading ?? self.isLoading,
            shouldRetry: shouldRetry ?? self.shouldRetry
        )
    }
    
    var hasLocation: Bool {
        return location != nil
    }
}

