//
//  ArrowView.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 16.04.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit

class ArrowView: UIView {
    override func draw(_ rect: CGRect) {
        StyleKit.drawPlainArrowUp(frame: rect, resizing: .aspectFit)
    }
}
