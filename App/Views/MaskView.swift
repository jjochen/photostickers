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
    var maskRect: CGRect?
    var color: UIColor?

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        let fillColor = self.color ?? UIColor.white
        fillColor.setFill()
        UIRectFill(rect)

        context.setBlendMode(.destinationOut)
        let path = self.maskPath(forRect: rect)
        path.fill()
        context.setBlendMode(.normal)
    }

    fileprivate func maskPath(forRect rect: CGRect) -> UIBezierPath {
        let maskRect = self.maskRect ?? rect
        let path = self.maskPath?.path(in: maskRect) ?? UIBezierPath(ovalIn: maskRect)
        return path
    }
}
