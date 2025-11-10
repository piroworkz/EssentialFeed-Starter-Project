//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by David Luna on 09/11/25.
//

import Foundation

public class CommonPresenter<T, View: CommonView> {
    public typealias Mapper = (T) throws -> View.UIState
    private let errorView: ErrorMessageView
    private let loadingView: LoadingView
    private let view: View
    private let mapper: Mapper
    
    public init(errorView: ErrorMessageView, loadingView: LoadingView, view: View, mapper: @escaping Mapper) {
        self.errorView = errorView
        self.loadingView = loadingView
        self.view = view
        self.mapper = mapper
    }
    
    public static var loadErrorMessage: String {
        return String(localized: .Shared.genericConnectionError)
    }
    
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(.loading)
    }
    
    public func didFinishLoading(with resource: T) {
        do {
            view.display(try mapper(resource))
            loadingView.display(.notLoading)
        } catch {
            didFinishLoading(with: error)
        }
    }
    
    public func didFinishLoading(with error: Error) {
        errorView.display(.error(message: Self.loadErrorMessage))
        loadingView.display(.notLoading)
    }
}
