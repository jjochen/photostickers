//
//  UIView+Extensions.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 15/03/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit

extension UIView {
    func convertBounds(to view: UIView?) -> CGRect {
        return self.convert(self.bounds, to: view)
    }
}
