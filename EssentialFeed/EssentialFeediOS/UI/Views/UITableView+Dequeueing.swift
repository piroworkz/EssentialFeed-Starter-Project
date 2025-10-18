//
//  UITableView+Dequeueing.swift
//  EssentialFeed
//
//  Created by David Luna on 18/10/25.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
