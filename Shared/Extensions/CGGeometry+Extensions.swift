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

    func flippedOrigin() -> CGSize {
        return CGSize(width: width, height: -height)
    }
}

extension CGPoint {
    func flippedOrigin() -> CGPoint {
        return CGPoint(x: x, y: -y)
    }
}

extension CGRect {
    var minSideLength: CGFloat {
        return min(width, height)
    }

    func flippedOrigin() -> CGRect {
        return CGRect(origin: origin.flippedOrigin(), size: size.flippedOrigin())
    }
}
