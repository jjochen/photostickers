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

        guard let colorSpace = croppedImageRef.colorSpace else {
            Logger.shared.error("Couldn't get color space")
            return nil
        }

        let renderedImageRect = CGRect(origin: .zero, size: Sticker.renderedSize).integral
        guard let context: CGContext = CGContext(
            data: nil,
            width: Int(renderedImageRect.size.width),
            height: Int(renderedImageRect.size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: 0 | CGImageAlphaInfo.premultipliedFirst.rawValue
        ) else {
            Logger.shared.error("Couldn't create image context")
            return nil
        }
        context.interpolationQuality = .high

        let shadowOffset = CGSize(width: 3, height: -3)
        let shadowBlur = CGFloat(15)
        let shadowColor = UIColor.black

        let leftShadowInset = max(0, shadowBlur - shadowOffset.width)
        let rightShadowInset = max(0, shadowBlur + shadowOffset.width)
        let bottomShadowInset = max(0, shadowBlur - shadowOffset.height)
        let topShadowInset = max(0, shadowBlur + shadowOffset.height)

        var imageDrawRect = CGRect()
        imageDrawRect.origin.x = leftShadowInset
        imageDrawRect.origin.y = bottomShadowInset
        imageDrawRect.size.width = CGFloat(context.width) - leftShadowInset - rightShadowInset
        imageDrawRect.size.height = CGFloat(context.height) - bottomShadowInset - topShadowInset

        let clipPath = mask.path(in: imageDrawRect, flipped: true)

        context.saveGState()
        context.beginPath()
        context.addPath(clipPath.cgPath)
        context.closePath()
        context.setShadow(offset: shadowOffset, blur: shadowBlur, color: shadowColor.cgColor)
        context.drawPath(using: .fill)
        context.restoreGState()

        context.saveGState()
        context.beginPath()
        context.addPath(clipPath.cgPath)
        context.closePath()
        context.clip()
        context.draw(croppedImageRef, in: imageDrawRect.integral)
        context.restoreGState()

        guard let renderedImageRef = context.makeImage() else {
            Logger.shared.error("Couldn't make image from context")
            return nil
        }

        return UIImage(cgImage: renderedImageRef)
    }
}
