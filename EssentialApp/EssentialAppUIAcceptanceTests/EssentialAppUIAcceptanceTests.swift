//
//  EssentialAppUIAcceptanceTests.swift
//  EssentialAppUIAcceptanceTests
//
//  Created by David Luna on 31/10/25.
//

import XCTest

final class EssentialAppUIAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = buildApp(connectivity: "online", reset: true)
        app.launch()

        XCTAssertEqual(feedCells(in: app).count, 2)
        XCTAssertTrue(firstFeedImage(in: app).exists)
    }

    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let onlineApp = buildApp(connectivity: "online", reset: true)
        onlineApp.launch()

        let offlineApp = buildApp(connectivity: "offline")
        offlineApp.launch()

        XCTAssertEqual(feedCells(in: offlineApp).count, 2)
        XCTAssertTrue(firstFeedImage(in: offlineApp).exists)
    }

    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let app = buildApp(connectivity: "offline", reset: true)
        app.launch()

        XCTAssertEqual(feedCells(in: app).count, 0)
    }
}

extension EssentialAppUIAcceptanceTests {
    private func buildApp(connectivity: String, reset: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        var args: [String] = ["-connectivity", connectivity]
        if reset { args.insert("-reset", at: 0) }
        app.launchArguments = args
        return app
    }

    private func feedCells(in app: XCUIApplication) -> XCUIElementQuery {
        app.cells.matching(identifier: "feed-image-cell")
    }

    private func firstFeedImage(in app: XCUIApplication) -> XCUIElement {
        app.images.matching(identifier: "feed-image-view").firstMatch
    }
}
