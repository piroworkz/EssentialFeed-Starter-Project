//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by David Luna on 26/10/25.
//

import Foundation

public final class FeedImagePresenter {
    public static func map(_ model: FeedImage) -> FeedImageState {
        FeedImageState(description: model.description, location: model.location)
    }
}
