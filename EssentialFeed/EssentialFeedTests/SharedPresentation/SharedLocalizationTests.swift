//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by David Luna on 18/10/25.
//

import XCTest
@testable import EssentialFeed

final class SharedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeyANdValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle(for: LoadResourcePresenter<String, FakeView>.self)
        
        assertLocalizationKeysAndValuesExist(in: bundle, table)
    }
    
}
