//
//  AppIconView.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 09.04.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit

class AppIconView: UIView {
    override func draw(_ rect: CGRect) {
        StyleKit.drawAppIcon(frame: rect, resizing: .aspectFit)
    }
}
