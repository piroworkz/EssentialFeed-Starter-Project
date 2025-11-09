//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by David Luna on 18/10/25.
//

import XCTest
@testable import EssentialFeed

final class FeedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeyANdValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        
        assertLocalizationKeysAndValuesExist(in: bundle, table)
    }
}
