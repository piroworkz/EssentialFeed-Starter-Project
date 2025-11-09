//
//  LocalizationUtils.swift
//  EssentialFeed
//
//  Created by David Luna on 09/11/25.
//
import Foundation
import XCTest

func assertLocalizationKeysAndValuesExist(in bundle: Bundle, _ table: String, file: StaticString = #file, line: UInt = #line) {
    let localizationBundles = allLocalizationBundles(in: bundle, file: file, line: line)
    let localizedKeys = allLocalizedKeys(in: localizationBundles, table: table, file: file, line: line)
    
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
