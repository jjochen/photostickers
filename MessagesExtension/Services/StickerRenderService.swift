//
//  StickerRenderer.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 02/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol HasStickerRenderService {
    var stickerRenderService: StickerRenderService { get }
}

class StickerRenderService {
    private let renderedImageSize = Sticker.renderedSize
    private let shadowOffset = CGSize(width: 0, height: -4)
    private let shadowBlur = CGFloat(12)
    private let shadowColor = UIColor.black
    private let backgroundColor = UIColor.white
}

extension StickerRenderService {
    func render(_ stickerInfo: StickerInfo) -> Observable<UIImage?> {
        return Observable.combineLatest(stickerInfo.originalImage.asObservable(), stickerInfo.cropBounds.asObservable(), stickerInfo.mask.asObservable()) { [weak self] (originalImage, cropBounds, mask) -> UIImage? in
            self?.render(originalImage, mask: mask, cropBounds: cropBounds)
        }
    }

    func render(_ originalImage: UIImage?, mask: Mask, cropBounds: CGRect? = nil) -> UIImage? {
        guard let image = originalImage else {
            fatalErrorWhileDebugging("Couldn't render empty image")
            return nil
        }

        if image.imageOrientation != .up {
            fatalErrorWhileDebugging("UIImageOrientation.up is only allowed image orientation!")
        }

        guard let imageRef = originalImage?.cgImage else {
            fatalErrorWhileDebugging("Couldn't get CGImageRef")
            return nil
        }

        let bounds = cropBounds ?? CGRect(origin: .zero, size: image.size)
        let scaledBounds = bounds.applying(CGAffineTransform(scaleX: image.scale, y: image.scale))

        guard let croppedImageRef = imageRef.cropping(to: scaledBounds) else {
            fatalErrorWhileDebugging("Couldn't crop image to new bounds")
            return nil
        }

        guard let context = context else {
            fatalErrorWhileDebugging("Couldn't create image context")
            return nil
        }

        let clipPath = mask.path(in: imageDrawRect, flipped: true).cgPath

        drawBackgroundAndShadow(path: clipPath, in: context)
        drawImage(croppedImageRef, clipPath: clipPath, in: context)

        guard let renderedImageRef = context.makeImage() else {
            fatalErrorWhileDebugging("Couldn't make image from context")
            return nil
        }

        return UIImage(cgImage: renderedImageRef)
    }
}

private extension StickerRenderService {
    func drawBackgroundAndShadow(path: CGPath, in context: CGContext) {
        context.saveGState()
        context.beginPath()
        context.addPath(path)
        context.closePath()
        context.setFillColor(backgroundColor.cgColor)
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

    var context: CGContext? {
        let context = CGContext(
            data: nil,
            width: Int(renderedImageSize.width),
            height: Int(renderedImageSize.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: 0 | CGImageAlphaInfo.premultipliedFirst.rawValue
        )
        context?.interpolationQuality = .high
        return context
    }

    var imageDrawRect: CGRect {
        let leftShadowInset = max(0, shadowBlur - shadowOffset.width)
        let rightShadowInset = max(0, shadowBlur + shadowOffset.width)
        let bottomShadowInset = max(0, shadowBlur - shadowOffset.height)
        let topShadowInset = max(0, shadowBlur + shadowOffset.height)

        let maxWidth = renderedImageSize.width - leftShadowInset - rightShadowInset
        let maxHeight = renderedImageSize.height - bottomShadowInset - topShadowInset

        let xScale = maxWidth / renderedImageSize.width
        let yScale = maxHeight / renderedImageSize.height
        let scale = min(xScale, yScale)

        var imageDrawRect = CGRect()
        imageDrawRect.origin.x = leftShadowInset
        imageDrawRect.origin.y = bottomShadowInset
        imageDrawRect.size.width = renderedImageSize.width * scale
        imageDrawRect.size.height = renderedImageSize.height * scale
        return imageDrawRect.integral
    }
}
