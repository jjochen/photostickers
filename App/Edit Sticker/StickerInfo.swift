//
//  StickerInfo.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 24/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import RxSwift

class StickerInfo {
    let uuid: Variable<String>
    let localizedDescription: Variable<String>
    let originalImage: Variable<UIImage?>
    let renderedSticker: Variable<UIImage?>
    let cropBounds: Variable<CGRect>
    let sortOrder: Variable<Int>

    init(uuid: String,
         localizedDescription: String,
         originalImage: UIImage?,
         renderedSticker: UIImage?,
         cropBounds: CGRect,
         sortOrder: Int) {
        self.uuid = Variable(uuid)
        self.localizedDescription = Variable(localizedDescription)
        self.originalImage = Variable(originalImage)
        self.renderedSticker = Variable(renderedSticker)
        self.cropBounds = Variable(cropBounds)
        self.sortOrder = Variable(sortOrder)
    }

    convenience init(sticker: Sticker!) {
        self.init(uuid: sticker.uuid,
                  localizedDescription: sticker.localizedDescription,
                  originalImage: sticker.originalImage,
                  renderedSticker: sticker.renderedSticker,
                  cropBounds: sticker.cropBounds,
                  sortOrder: sticker.sortOrder)
    }
}
