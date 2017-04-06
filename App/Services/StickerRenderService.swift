//
//  StickerRenderer.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 02/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Log

protocol StickerRenderServiceType {
    func render(_ stickerInfo: StickerInfo) -> Observable<UIImage?>
}

class StickerRenderService: StickerRenderServiceType {

    func render(_ stickerInfo: StickerInfo) -> Observable<UIImage?> {
        return Observable.combineLatest(stickerInfo.originalImage.asObservable(), stickerInfo.cropBounds.asObservable(), stickerInfo.mask.asObservable()) { [weak self](originalImage, cropBounds, mask) -> UIImage? in
            self?.renderedImage(originalImage, cropBounds: cropBounds, mask: mask)
        }
    }
}

fileprivate extension StickerRenderService {

    func renderedImage(_ originalImage: UIImage?, cropBounds: CGRect, mask: Mask) -> UIImage? {

        guard let image = originalImage else {
            Logger.shared.error("Couldn't render empty image")
            return nil
        }

        if image.imageOrientation != .up {
            Logger.shared.warning("UIImageOrientation.up is only allowed image orientation!")
        }

        guard let imageRef = originalImage?.cgImage else {
            Logger.shared.error("Couldn't get CGImageRef")
            return nil
        }

        guard let croppedImageRef = imageRef.cropping(to: cropBounds) else {
            Logger.shared.error("Couldn't crop image to new bounds")
            return nil
        }

        guard let context = context(for: croppedImageRef) else {
            Logger.shared.error("Couldn't create image context")
            return nil
        }
        context.interpolationQuality = .high

        let clipPath = mask.path(in: imageDrawRect, flipped: true).cgPath

        drawShadow(path: clipPath, in: context)
        drawImage(croppedImageRef, clipPath: clipPath, in: context)

        guard let renderedImageRef = context.makeImage() else {
            Logger.shared.error("Couldn't make image from context")
            return nil
        }

        return UIImage(cgImage: renderedImageRef)
    }

    func drawShadow(path: CGPath, in context: CGContext) {
        context.saveGState()
        context.beginPath()
        context.addPath(path)
        context.closePath()
        context.setShadow(offset: shadowOffset, blur: shadowBlur, color: shadowColor.cgColor)
        context.drawPath(using: .fill)
        context.restoreGState()
    }

    func drawImage(_ imageRef: CGImage, clipPath: CGPath, in context: CGContext) {
        context.saveGState()
        context.beginPath()
        context.addPath(clipPath)
        context.closePath()
        context.clip()
        context.draw(imageRef, in: imageDrawRect.integral)
        context.restoreGState()
    }

    func context(for imageRef: CGImage) -> CGContext? {

        guard let colorSpace = imageRef.colorSpace else {
            Logger.shared.error("Couldn't get color space")
            return nil
        }

        let context = CGContext(
            data: nil,
            width: Int(renderedImageRect.size.width),
            height: Int(renderedImageRect.size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: 0 | CGImageAlphaInfo.premultipliedFirst.rawValue
        )
        return context
    }

    var shadowOffset: CGSize {
        return CGSize(width: 0, height: -4)
    }

    var shadowBlur: CGFloat {
        return CGFloat(12)
    }

    var shadowColor: UIColor {
        return UIColor.black
    }

    var renderedImageRect: CGRect {
        return CGRect(origin: .zero, size: Sticker.renderedSize).integral
    }

    var imageDrawRect: CGRect {
        let leftShadowInset = max(0, shadowBlur - shadowOffset.width)
        let rightShadowInset = max(0, shadowBlur + shadowOffset.width)
        let bottomShadowInset = max(0, shadowBlur - shadowOffset.height)
        let topShadowInset = max(0, shadowBlur + shadowOffset.height)

        let maxWidth = renderedImageRect.width - leftShadowInset - rightShadowInset
        let maxHeight = renderedImageRect.height - bottomShadowInset - topShadowInset

        let xScale = maxWidth / renderedImageRect.width
        let yScale = maxHeight / renderedImageRect.height
        let scale = min(xScale, yScale)

        var imageDrawRect = CGRect()
        imageDrawRect.origin.x = leftShadowInset
        imageDrawRect.origin.y = bottomShadowInset
        imageDrawRect.size.width = renderedImageRect.width * scale
        imageDrawRect.size.height = renderedImageRect.height * scale
        return imageDrawRect.integral
    }
}
