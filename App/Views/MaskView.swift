//
//  MaskView.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 06/03/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit
import CoreGraphics

class MaskView: UIView {

    var maskPath: Mask?

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        UIColor.white.setFill()
        UIRectFill(rect)

        context.setBlendMode(.destinationOut)
        let path = self.currentPath(forRect: rect)
        path.fill()
        context.setBlendMode(.normal)
    }

    fileprivate func currentPath(forRect rect: CGRect) -> UIBezierPath {
        return self.maskPath?.path(in: rect) ?? UIBezierPath(ovalIn: rect)
    }
}
