//
//  UIDevice+Extensions.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 07.04.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit

extension UIDevice {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}
