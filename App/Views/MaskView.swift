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

    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

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

    fileprivate lazy var maskLayer: CAShapeLayer = {
        let mask = CAShapeLayer()
        mask.fillRule = kCAFillRuleEvenOdd
        return mask
    }()

    fileprivate lazy var theMaskView: UIView = {
        let maskView = UIView()
        maskView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        maskView.isUserInteractionEnabled = false
        maskView.backgroundColor = UIColor.black
        return maskView
    }()

    fileprivate func updateMask() {

        theMaskView.frame = self.bounds
        theMaskView.layer.mask = maskLayer
        let maskRect = self.maskRect ?? self.bounds
        let clipPath = self.maskPath?.path(in: maskRect) ?? UIBezierPath(ovalIn: maskRect)

        let path = CGMutablePath()
        path.addRect(self.bounds)
        path.addPath(clipPath.cgPath)

        maskLayer.path = path
        self.mask = theMaskView
    }
}
