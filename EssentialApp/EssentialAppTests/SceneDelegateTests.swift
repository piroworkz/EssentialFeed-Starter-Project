//
//  SceneDelegateTests.swift
//  EssentialAppTests
//
//  Created by David Luna on 01/11/25.
//

import XCTest
import EssentialFeediOS
@testable import EssentialApp

final class SceneDelegateTests: XCTestCase {
    
    func test_configureWindow_setsWindowAsKeyAndVisible() {
        let sut = SceneDelegate()
        let window = UIWindowSpy()
        
        sut.window = window
        sut.configureWindow()
        
        XCTAssertTrue(window.isAppKeyWindow, "Expected window to be key window")
        XCTAssertFalse(window.isHidden, "Expected window to be visible")
    }
    
    func test_configureWindow_configuresRootViewController() {
        let sut = SceneDelegate()
        
        sut.window = UIWindowSpy()
        sut.configureWindow()
        
        let rootVC = sut.window?.rootViewController
        let rootNavigationVC = rootVC as? UINavigationController
        let topController = rootNavigationVC?.topViewController
        
        XCTAssertNotNil(sut.window, "Expected window to be set")
        XCTAssertNotNil(rootNavigationVC, "Expected root view controller to be a navigation controller")
        XCTAssertTrue(topController is ListViewController, "Expected top view controller to be FeedViewController")
    }
    
    private class UIWindowSpy : UIWindow {
        private(set) var isAppKeyWindow = false
        
        override func makeKeyAndVisible() {
            isAppKeyWindow = true
            super.makeKeyAndVisible()
        }
        
    }
}
