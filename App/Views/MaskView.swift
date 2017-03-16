//
//  MaskView.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 06/03/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit
import CoreGraphics

class MaskView: UIVisualEffectView {

    var maskPath: Mask? {
        didSet {
            self.updateMask()
        }
    }

    var maskRect: CGRect? {
        didSet {
            self.updateMask()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateMask()
    }

    fileprivate lazy var maskLayer: CAShapeLayer = {
        let mask = CAShapeLayer()
        mask.fillRule = kCAFillRuleEvenOdd
        return mask
    }()

    fileprivate func updateMask() {
        if self.layer.mask == nil {
            self.layer.mask = self.maskLayer
        }

        let maskRect = self.maskRect ?? self.bounds
        let clipPath = self.maskPath?.path(in: maskRect) ?? UIBezierPath(ovalIn: maskRect)

        let path = CGMutablePath()
        path.addRect(self.bounds)
        path.addPath(clipPath.cgPath)

        self.maskLayer.path = path
    }
}
