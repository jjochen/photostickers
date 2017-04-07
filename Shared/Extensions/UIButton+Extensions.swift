//
//  UIButton+Extensions.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 07.04.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit

extension UIButton {
    func setBackgroundImages(image: @escaping (_ selected: Bool, _ highlighted: Bool) -> UIImage?) {
        setBackgroundImage(image(false, false), for: UIControlState())
        setBackgroundImage(image(false, false), for: UIControlState.normal)
        setBackgroundImage(image(false, true), for: UIControlState.highlighted)
        setBackgroundImage(image(true, false), for: UIControlState.selected)
        setBackgroundImage(image(true, true), for: [UIControlState.selected, UIControlState.highlighted])
    }
}
