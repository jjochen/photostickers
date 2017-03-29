//
//  CGRect+Extensions.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 27/03/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit

extension CGSize {
    var minSideLength: CGFloat {
        return min(width, height)
    }
}

extension CGRect {
    var minSideLength: CGFloat {
        return min(width, height)
    }
}
