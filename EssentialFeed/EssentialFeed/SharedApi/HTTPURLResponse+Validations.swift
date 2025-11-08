//
//  File.swift
//  EssentialFeed
//
//  Created by David Luna on 08/11/25.
//
import Foundation

extension HTTPURLResponse {
    
    var isOK: Bool {
        return statusCode == 200
    }
    
    func validateStatusCode(byRange validStatusCodes: ClosedRange<Int>) -> Bool {
        return validStatusCodes.contains(statusCode)
    }
    
}
