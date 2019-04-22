//
//  UIImage+Resize.swift
//
//  Created by Trevor Harmon on 08/05/09.
//  Swift 3 port by Giacomo Boccardo on 09/15/2016.
//
//  Free for personal or commercial use, with or without modification
//  No warranty is expressed or implied.
//
import UIKit

public extension UIImage {
    // Returns a copy of this image that is cropped to the given bounds.
    // The bounds will be adjusted using CGRectIntegral.
    // This method ignores the image's imageOrientation setting.
    func croppedImage(_ bounds: CGRect) -> UIImage {
        let imageRef: CGImage = cgImage!.cropping(to: bounds)!
        return UIImage(cgImage: imageRef)
    }

    func thumbnailImage(_ thumbnailSize: Int, transparentBorder borderSize: Int, cornerRadius: Int, interpolationQuality quality: CGInterpolationQuality) -> UIImage {
        let resizedImage = resizedImageWithContentMode(.scaleAspectFill, bounds: CGSize(width: CGFloat(thumbnailSize), height: CGFloat(thumbnailSize)), interpolationQuality: quality)

        // Crop out any part of the image that's larger than the thumbnail size
        // The cropped rect must be centered on the resized image
        // Round the origin points so that the size isn't altered when CGRectIntegral is later invoked
        let cropRect = CGRect(
            x: round((resizedImage.size.width - CGFloat(thumbnailSize)) / 2),
            y: round((resizedImage.size.height - CGFloat(thumbnailSize)) / 2),
            width: CGFloat(thumbnailSize),
            height: CGFloat(thumbnailSize)
        )

        let croppedImage = resizedImage.croppedImage(cropRect)
        let transparentBorderImage = borderSize != 0 ? croppedImage.transparentBorderImage(borderSize) : croppedImage

        return transparentBorderImage.roundedCornerImage(cornerSize: cornerRadius, borderSize: borderSize)
    }

    // Returns a rescaled copy of the image, taking into account its orientation
    // The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
    func resizedImage(_ newSize: CGSize, interpolationQuality quality: CGInterpolationQuality) -> UIImage {
        var drawTransposed: Bool

        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            drawTransposed = true
        default:
            drawTransposed = false
        }

        return resizedImage(
            newSize,
            transform: transformForOrientation(newSize),
            drawTransposed: drawTransposed,
            interpolationQuality: quality
        )
    }

    func resizedImageWithContentMode(_ contentMode: UIView.ContentMode, bounds: CGSize, interpolationQuality quality: CGInterpolationQuality) -> UIImage {
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        var ratio: CGFloat = 1

        switch contentMode {
        case .scaleAspectFill:
            ratio = max(horizontalRatio, verticalRatio)
        case .scaleAspectFit:
            ratio = min(horizontalRatio, verticalRatio)
        default:
            fatalErrorWhileDebugging("Unsupported content mode \(contentMode)")
        }

        let newSize: CGSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        return resizedImage(newSize, interpolationQuality: quality)
    }

    fileprivate func normalizeBitmapInfo(_ bI: CGBitmapInfo) -> UInt32 {
        var alphaInfo: UInt32 = bI.rawValue & CGBitmapInfo.alphaInfoMask.rawValue

        if alphaInfo == CGImageAlphaInfo.last.rawValue {
            alphaInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        }

        if alphaInfo == CGImageAlphaInfo.first.rawValue {
            alphaInfo = CGImageAlphaInfo.premultipliedFirst.rawValue
        }

        var newBI: UInt32 = bI.rawValue & ~CGBitmapInfo.alphaInfoMask.rawValue

        newBI |= alphaInfo

        return newBI
    }

    fileprivate func resizedImage(_ newSize: CGSize, transform: CGAffineTransform, drawTransposed transpose: Bool, interpolationQuality quality: CGInterpolationQuality) -> UIImage {
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        let transposedRect = CGRect(x: 0, y: 0, width: newRect.size.height, height: newRect.size.width)
        let imageRef: CGImage = cgImage!

        // Build a context that's the same dimensions as the new size
        let bitmap: CGContext = CGContext(
            data: nil,
            width: Int(newRect.size.width),
            height: Int(newRect.size.height),
            bitsPerComponent: imageRef.bitsPerComponent,
            bytesPerRow: 0,
            space: imageRef.colorSpace!,
            bitmapInfo: normalizeBitmapInfo(imageRef.bitmapInfo)
        )!

        // Rotate and/or flip the image if required by its orientation
        bitmap.concatenate(transform)

        // Set the quality level to use when rescaling
        bitmap.interpolationQuality = quality

        // Draw into the context; this scales the image
        bitmap.draw(imageRef, in: transpose ? transposedRect : newRect)

        // Get the resized image from the context and a UIImage
        let newImageRef: CGImage = bitmap.makeImage()!
        return UIImage(cgImage: newImageRef)
    }

    fileprivate func transformForOrientation(_ newSize: CGSize) -> CGAffineTransform {
        var transform: CGAffineTransform = CGAffineTransform.identity

        switch imageOrientation {
        case .down, .downMirrored:
            // EXIF = 3 / 4
            transform = transform.translatedBy(x: newSize.width, y: newSize.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            // EXIF = 6 / 5
            transform = transform.translatedBy(x: newSize.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        case .right, .rightMirrored:
            // EXIF = 8 / 7
            transform = transform.translatedBy(x: 0, y: newSize.height)
            transform = transform.rotated(by: -CGFloat.pi / 2)
        default:
            break
        }

        switch imageOrientation {
        case .upMirrored, .downMirrored:
            // EXIF = 2 / 4
            transform = transform.translatedBy(x: newSize.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            // EXIF = 5 / 7
            transform = transform.translatedBy(x: newSize.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }

        return transform
    }
}
