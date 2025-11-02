//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by David Luna on 02/11/25.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
