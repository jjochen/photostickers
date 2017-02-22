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
    func render(_ sticker: Sticker?) -> Observable<Sticker?>
}

class StickerRenderService: StickerRenderServiceType {

    let imageStoreService: ImageStoreServiceType

    init(imageStoreService: ImageStoreServiceType) {
        self.imageStoreService = imageStoreService
    }

    func render(_ sticker: Sticker?) -> Observable<Sticker?> {
        return Observable<Sticker?>.create({ (observer) -> Disposable in
            self.renderSticker(sticker)
            observer.onNext(sticker)
            observer.onCompleted()
            return Disposables.create()
        })
    }

    fileprivate func renderSticker(_ sticker: Sticker?) {
        guard let sticker = sticker else {
            return
        }
        guard let renderedImage = self.renderedImage(for: sticker) else {
            Logger.shared.error("Could not render image for sticker: \(sticker)")
            return
        }
        guard let url = imageStoreService.storeImage(renderedImage, forKey: sticker.uuid, inCategory: "stickers") else {
            Logger.shared.error("Could not store image for sticker: \(sticker)")
            return
        }
        sticker.renderedStickerFilePath = url.path
    }

    fileprivate func renderedImage(for sticker: Sticker) -> UIImage? {
        guard var image = sticker.originalImage else {
            return nil
        }
        let cropBounds = sticker.cropBounds
        image = image.croppedImage(cropBounds)
        image = image.resizedImageWithContentMode(.scaleAspectFit, bounds: Sticker.renderedSize, interpolationQuality: .high)
        let cornerRadius = Int(floor(min(image.size.width, image.size.height) / 2))
        image = image.roundedCornerImage(cornerSize: cornerRadius, borderSize: 0) // todo: better handling of masks

        return image
    }
}
