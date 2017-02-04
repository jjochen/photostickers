//
//  StickerRenderer.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 02/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import UIKit

struct StickerRenderer {

    static func render(_ sticker: Sticker) {
        guard var image = sticker.originalImage else {
            return
        }
        let cropBounds = sticker.cropBounds
        image = image.croppedImage(cropBounds)
        image = image.resizedImageWithContentMode(.scaleAspectFit, bounds: Sticker.renderedSize, interpolationQuality: .high)
        sticker.renderedSticker = image
    }
}
