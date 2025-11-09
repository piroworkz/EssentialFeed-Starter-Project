//
//  CommonView.swift
//  EssentialFeed
//
//  Created by David Luna on 09/11/25.
//

public protocol CommonView {
    associatedtype UIState
    func display(_ state: UIState)
}
