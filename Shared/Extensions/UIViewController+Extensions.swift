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
        self.beginAppearanceTransition(true, animated: false)
        self.endAppearanceTransition()
    }

    //    func performSegue(_ identifier: SegueIdentifier) {
    //        self.performSegue(withIdentifier: identifier.rawValue, sender: self)
    //    }

    func findChildViewControllerOfType(_ klass: AnyClass) -> UIViewController? {
        for child in childViewControllers {
            if child.isKind(of: klass) {
                return child
            }
        }
        return nil
    }
}
