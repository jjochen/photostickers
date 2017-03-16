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

    fileprivate var maskLayer: CAShapeLayer?

    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    fileprivate func commonInit() {
        self.backgroundColor = UIColor.clear
        self.maskLayer = CAShapeLayer()
        self.maskLayer?.fillRule = kCAFillRuleEvenOdd
        self.layer.mask = self.maskLayer
        self.effect = UIBlurEffect(style: UIBlurEffectStyle.light)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateMask()
    }

    fileprivate func updateMask() {
        let maskRect = self.maskRect ?? self.bounds
        let clipPath = self.maskPath?.path(in: maskRect) ?? UIBezierPath(ovalIn: maskRect)

        let path = CGMutablePath()
        path.addRect(self.bounds)
        path.addPath(clipPath.cgPath)

        self.maskLayer?.path = path
    }
}
