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
        setBackgroundImage(image(false, false), for: UIControl.State())
        setBackgroundImage(image(false, false), for: UIControl.State.normal)
        setBackgroundImage(image(false, true), for: UIControl.State.highlighted)
        setBackgroundImage(image(true, false), for: UIControl.State.selected)
        setBackgroundImage(image(true, true), for: [UIControl.State.selected, UIControl.State.highlighted])
    }
}
