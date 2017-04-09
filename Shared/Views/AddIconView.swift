//
//  AddMoreIconView.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 09.04.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit

class AddIconView: UIControl {

    override var isHighlighted: Bool {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        StyleKit.drawAddIcon(frame: rect, resizing: .aspectFit, highlighted: isHighlighted)
    }
}
