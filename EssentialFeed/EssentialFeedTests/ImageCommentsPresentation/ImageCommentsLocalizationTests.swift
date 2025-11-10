//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by David Luna on 18/10/25.
//

import XCTest
@testable import EssentialFeed

final class ImageCommentsLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeyANdValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
            
        assertLocalizationKeysAndValuesExist(in: bundle, table)
    }
}
