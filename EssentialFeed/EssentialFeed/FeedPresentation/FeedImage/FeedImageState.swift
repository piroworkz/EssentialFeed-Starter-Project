//
//  FeedImageState.swift
//  EssentialFeed
//
//  Created by David Luna on 26/10/25.
//

public struct FeedImageState<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public init(
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
    var hasLocation: Bool {
        return location != nil
    }
    
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
}
