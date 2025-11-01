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
    
    func test_sceneWillConnectToSession_configuresRootViewController() {
        let sut = SceneDelegate()
        
        sut.window = UIWindow()
        sut.configureWindow()
        
        let rootVC = sut.window?.rootViewController
        let rootNavigationVC = rootVC as? UINavigationController
        let topController = rootNavigationVC?.topViewController
        
        XCTAssertNotNil(sut.window, "Expected window to be set")
        XCTAssertNotNil(rootNavigationVC, "Expected root view controller to be a navigation controller")
        XCTAssertTrue(topController is FeedViewController, "Expected top view controller to be FeedViewController")
    }
}
