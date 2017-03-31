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
        return Observable.combineLatest(stickerInfo.originalImage.asObservable(), stickerInfo.cropBounds.asObservable()) { [weak self](originalImage, cropBounds) -> UIImage? in
            self?.renderedImage(originalImage, cropBounds: cropBounds)
        }
    }

    fileprivate func renderedImage(_ originalImage: UIImage?, cropBounds: CGRect) -> UIImage? {
        guard var image = originalImage else {
            return nil
        }
        image = image.croppedImage(cropBounds)
        image = image.resizedImageWithContentMode(.scaleAspectFit, bounds: Sticker.renderedSize, interpolationQuality: .high)
        let cornerRadius = Int(floor(min(image.size.width, image.size.height) / 2))
        image = image.roundedCornerImage(cornerSize: cornerRadius, borderSize: 0)
        // TODO: better handling of masks

        return image
    }
}
