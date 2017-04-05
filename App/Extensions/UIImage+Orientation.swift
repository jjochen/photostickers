//
//  UIImage+Orientation.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 05.04.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit

extension UIImage {

    func fixOrientation() -> UIImage {

        if imageOrientation == UIImageOrientation.up {
            return self
        }

        var transform: CGAffineTransform = CGAffineTransform.identity

        if imageOrientation == UIImageOrientation.down || imageOrientation == UIImageOrientation.downMirrored {
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        }

        if imageOrientation == UIImageOrientation.left || imageOrientation == UIImageOrientation.leftMirrored {
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        }

        if imageOrientation == UIImageOrientation.right || imageOrientation == UIImageOrientation.rightMirrored {
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -CGFloat.pi / 2)
        }

        if imageOrientation == UIImageOrientation.upMirrored || imageOrientation == UIImageOrientation.downMirrored {
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }

        if imageOrientation == UIImageOrientation.leftMirrored || imageOrientation == UIImageOrientation.rightMirrored {
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }

        let ctx: CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                                       bitsPerComponent: cgImage!.bitsPerComponent, bytesPerRow: 0,
                                       space: cgImage!.colorSpace!,
                                       bitmapInfo: cgImage!.bitmapInfo.rawValue)!

        ctx.concatenate(transform)

        if imageOrientation == UIImageOrientation.left ||
            imageOrientation == UIImageOrientation.leftMirrored ||
            imageOrientation == UIImageOrientation.right ||
            imageOrientation == UIImageOrientation.rightMirrored {
            ctx.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        } else {
            ctx.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }

        return UIImage(cgImage: ctx.makeImage()!)
    }
}
