//
//  MaskView.swift
//  MessagesExtension
//
//  Created by Jochen on 01.01.20.
//  Copyright © 2020 Jochen Pfeiffer. All rights reserved.
//

import UIKit

protocol MaskViewDelegate: AnyObject {
    func maskRect(inMaskView maskView: MaskView) -> CGRect
}

class MaskView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    weak var delegate: MaskViewDelegate?

    var maskType: Mask? {
        didSet {
            configureLayers()
        }
    }

    var shadowHidden: Bool {
        get {
            shadowLayer.isHidden
        }
        set {
            shadowLayer.isHidden = newValue
        }
    }

    fileprivate lazy var maskLayer: CAShapeLayer = {
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        return maskLayer
    }()

    fileprivate lazy var shadowLayer: CAShapeLayer = {
        let shadowLayer = CAShapeLayer()
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOpacity = 1
        shadowLayer.shadowOffset = CGSize(width: 0, height: 3)
        shadowLayer.shadowRadius = 6
        return shadowLayer
    }()
}

extension MaskView {
    override func layoutSubviews() {
        super.layoutSubviews()
        maskLayer.frame = bounds
        shadowLayer.frame = bounds
        configureLayers()
    }
}

private extension MaskView {
    func commonInit() {
        layer.addSublayer(shadowLayer)
    }
}

private extension MaskView {
    var maskRect: CGRect {
        return delegate?.maskRect(inMaskView: self) ?? bounds
    }

    func configureLayers() {
        guard let mask = maskType else { return }
        let rect = maskRect

        let maskPath = mask.maskPath(in: bounds, maskRect: rect)
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer

        let shadowPath = mask.path(in: rect)
        shadowLayer.shadowPath = shadowPath.cgPath
    }
}
