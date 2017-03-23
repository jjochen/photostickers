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
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    func commonInit() {
        self.theMaskView.layer.mask = self.maskLayer
        self.mask = self.theMaskView
        self.updateMask()
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

    override func layoutSubviews() {
        super.layoutSubviews()
        //        self.theMaskView.frame = self.bounds
        //        self.updateMask()
    }

    fileprivate lazy var maskLayer: CAShapeLayer = {
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = kCAFillRuleEvenOdd
        return maskLayer
    }()

    fileprivate lazy var theMaskView: UIView = {
        let maskView = UIView()
        maskView.isUserInteractionEnabled = false
        maskView.backgroundColor = UIColor.black
        return maskView
    }()

    fileprivate func updateMask() {
        self.theMaskView.frame = self.bounds
        self.maskLayer.frame = self.theMaskView.bounds

        let maskRect = self.maskRect ?? self.bounds
        let clipPath = self.maskPath?.path(in: maskRect) ?? UIBezierPath(ovalIn: maskRect)

        let path = CGMutablePath()
        path.addRect(self.bounds)
        path.addPath(clipPath.cgPath)

        self.maskLayer.path = path
    }
}
