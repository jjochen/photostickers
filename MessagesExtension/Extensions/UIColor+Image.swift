//
//  UIColor+Image.swift
//  MessagesExtension
//
//  Created by Jochen on 22.04.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import UIKit

extension UIColor {
    func image(withSize size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.saveGState()
        context.setFillColor(cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        context.restoreGState()
        return image
    }
}
