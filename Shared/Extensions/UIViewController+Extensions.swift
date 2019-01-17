//
//  UIViewController+Extensions.swift
//  EasyHue
//
//  Created by Jochen Pfeiffer on 25.03.16.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import UIKit

extension UIViewController {
    func loadViewProgrammatically() {
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }

    func performSegue(_ identifier: SegueIdentifier) {
        performSegue(withIdentifier: identifier.rawValue, sender: self)
    }

    func findChildViewControllerOfType(_ klass: AnyClass) -> UIViewController? {
        for child in children {
            if child.isKind(of: klass) {
                return child
            }
        }
        return nil
    }
}
