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
        let localizationBundles = allLocalizationBundles(in: bundle)
        let localizedKeys = allLocalizedKeys(in: localizationBundles, table: table)
        
        localizationBundles.forEach { (localization, bundle) in
            localizedKeys.forEach { key in
                let value = bundle.localizedString(forKey: key, value: nil, table: table)
                
                if value == key {
                    let language = Locale.current.localizedString(forLanguageCode: localization) ?? localization
                    XCTFail("Missing localized string for key: '\(key)' in localization: '\(language)'", file: #file, line: #line)
                }
            }
        }
    }
    
    private class FakeView: ResourceView {
        func display(_ viewModel: Void) {}
    }
    
    private typealias LocalizationBundle = (language: String, bundle: Bundle)
    
    private func allLocalizationBundles(in bundle: Bundle, file: StaticString = #file, line: UInt = #line) -> [LocalizationBundle] {
        return bundle.localizations.compactMap { language in
            guard
                let path = bundle.path(forResource: language, ofType: "lproj"),
                let localizationBundle = Bundle(path: path)
            else {
                XCTFail("Couldn't find bundle for localization: \(language)", file: file, line: line)
                return nil
            }
            
            return (language, localizationBundle)
        }
    }
    
    private func allLocalizedKeys(in localizationBundles: [LocalizationBundle], table: String, file: StaticString = #file, line: UInt = #line) -> Set<String> {
        return localizationBundles.reduce([]) { (acc, current) in
            guard
                let path = current.bundle.path(forResource: table, ofType: "strings"),
                let stringsDict = NSDictionary(contentsOfFile: path),
                let keys = stringsDict.allKeys as? [String]
            else {
                XCTFail("Couldn't load strings for table: \(table) in localization: \(current.language)", file: file, line: line)
                return acc
            }
            return acc.union(Set(keys))
        }
    }
}
