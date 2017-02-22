//
//  UIStoryboardSegue+Extensions.swift
//  EasyHue
//
//  Created by Jochen Pfeiffer on 24.03.16.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import UIKit

extension UIStoryboardSegue {
}

func ==(lhs: UIStoryboardSegue, rhs: SegueIdentifier) -> Bool {
    return lhs.identifier == rhs.rawValue
}
