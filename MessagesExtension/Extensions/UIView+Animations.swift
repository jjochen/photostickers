//
//  UIView+Animations.swift
//  MessagesExtension
//
//  Created by Jochen on 01.11.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import UIKit

extension UIView {
    class func animate(withDuration duration: TimeInterval, animated: Bool, animations: @escaping () -> Void) {
        if animated {
            animate(withDuration: duration, animations: animations)
        } else {
            animations()
        }
    }
}
