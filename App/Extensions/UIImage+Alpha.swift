//
//  UIImage+Alpha.swift
//
//  Created by Trevor Harmon on 09/20/09.
//  Swift 3 port by Giacomo Boccardo on 09/15/2016.
//
//  Free for personal or commercial use, with or without modification
//  No warranty is expressed or implied.
//
import UIKit

public extension UIImage {
    func hasAlpha() -> Bool {
        let alpha: CGImageAlphaInfo = cgImage!.alphaInfo
        return
            alpha == CGImageAlphaInfo.first ||
            alpha == CGImageAlphaInfo.last ||
            alpha == CGImageAlphaInfo.premultipliedFirst ||
            alpha == CGImageAlphaInfo.premultipliedLast
    }

    func imageWithAlpha() -> UIImage {
        if hasAlpha() {
            return self
        }

        let imageRef: CGImage = cgImage!
        let width = imageRef.width
        let height = imageRef.height

        // The bitsPerComponent and bitmapInfo values are hard-coded to prevent an "unsupported parameter combination" error
        let offscreenContext: CGContext = CGContext(
            data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
            space: imageRef.colorSpace!,
            bitmapInfo: 0 /* CGImageByteOrderInfo.orderMask.rawValue */ | CGImageAlphaInfo.premultipliedFirst.rawValue
        )!

        // Draw the image into the context and retrieve the new image, which will now have an alpha layer
        offscreenContext.draw(imageRef, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        let imageRefWithAlpha: CGImage = offscreenContext.makeImage()!

        return UIImage(cgImage: imageRefWithAlpha)
    }

    func transparentBorderImage(_ borderSize: Int) -> UIImage {
        let image = imageWithAlpha()

        let newRect = CGRect(
            x: 0, y: 0,
            width: image.size.width + CGFloat(borderSize) * 2,
            height: image.size.height + CGFloat(borderSize) * 2
        )

        // Build a context that's the same dimensions as the new size
        let bitmap: CGContext = CGContext(
            data: nil,
            width: Int(newRect.size.width), height: Int(newRect.size.height),
            bitsPerComponent: cgImage!.bitsPerComponent,
            bytesPerRow: 0,
            space: cgImage!.colorSpace!,
            bitmapInfo: cgImage!.bitmapInfo.rawValue
        )!

        // Draw the image in the center of the context, leaving a gap around the edges
        let imageLocation = CGRect(x: CGFloat(borderSize), y: CGFloat(borderSize), width: image.size.width, height: image.size.height)
        bitmap.draw(cgImage!, in: imageLocation)
        let borderImageRef: CGImage = bitmap.makeImage()!

        // Create a mask to make the border transparent, and combine it with the image
        let maskImageRef: CGImage = newBorderMask(borderSize, size: newRect.size)
        let transparentBorderImageRef: CGImage = borderImageRef.masking(maskImageRef)!
        return UIImage(cgImage: transparentBorderImageRef)
    }

    fileprivate func newBorderMask(_ borderSize: Int, size: CGSize) -> CGImage {
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()

        // Build a context that's the same dimensions as the new size
        let maskContext: CGContext = CGContext(
            data: nil,
            width: Int(size.width), height: Int(size.height),
            bitsPerComponent: 8, // 8-bit grayscale
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGBitmapInfo().rawValue | CGImageAlphaInfo.none.rawValue
        )!

        // Start with a mask that's entirely transparent
        maskContext.setFillColor(UIColor.black.cgColor)
        maskContext.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))

        // Make the inner part (within the border) opaque
        maskContext.setFillColor(UIColor.white.cgColor)
        maskContext.fill(CGRect(
            x: CGFloat(borderSize),
            y: CGFloat(borderSize),
            width: size.width - CGFloat(borderSize) * 2,
            height: size.height - CGFloat(borderSize) * 2
        ))

        // Get an image of the context
        return maskContext.makeImage()!
    }
}
