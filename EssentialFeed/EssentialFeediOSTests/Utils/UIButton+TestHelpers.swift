//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by David Luna on 16/10/25.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
