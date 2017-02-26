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

    // MARK: initial values
    let initialUUID: String
    let initialLocalizedDescription: String
    let initialOriginalImage: UIImage?
    let initialRenderedSticker: UIImage?
    let initialCropBounds: CGRect
    let initialSortOrder: Int

    // MARK: updated values
    let uuid: Variable<String>
    let localizedDescription: Variable<String>
    let originalImage: Variable<UIImage?>
    let renderedSticker: Variable<UIImage?>
    let cropBounds: Variable<CGRect>
    let sortOrder: Variable<Int>

    // MARK: initilizer
    init(uuid: String,
         localizedDescription: String,
         originalImage: UIImage?,
         renderedSticker: UIImage?,
         cropBounds: CGRect,
         sortOrder: Int) {

        self.initialUUID = uuid
        self.initialLocalizedDescription = localizedDescription
        self.initialOriginalImage = originalImage
        self.initialRenderedSticker = renderedSticker
        self.initialCropBounds = cropBounds
        self.initialSortOrder = sortOrder

        self.uuid = Variable(uuid)
        self.localizedDescription = Variable(localizedDescription)
        self.originalImage = Variable(originalImage)
        self.renderedSticker = Variable(renderedSticker)
        self.cropBounds = Variable(cropBounds)
        self.sortOrder = Variable(sortOrder)
    }

    convenience init() {
        self.init(uuid: "",
                  localizedDescription: "",
                  originalImage: nil,
                  renderedSticker: nil,
                  cropBounds: CGRect.zero,
                  sortOrder: 0)
    }

    convenience init(sticker: Sticker!) {
        self.init(uuid: sticker.uuid,
                  localizedDescription: sticker.localizedDescription,
                  originalImage: sticker.originalImage,
                  renderedSticker: sticker.renderedSticker,
                  cropBounds: sticker.cropBounds,
                  sortOrder: sticker.sortOrder)
    }

    // MARK: canges
    var uuidDidChange: Bool {
        return self.uuid.value != self.initialUUID
    }

    var localizedDescriptionDidChange: Bool {
        return self.localizedDescription.value != self.initialLocalizedDescription
    }

    var originalImageDidChange: Bool {
        return self.originalImage.value != self.initialOriginalImage
    }

    var renderedStickerDidChange: Bool {
        return self.renderedSticker.value != self.initialRenderedSticker
    }

    var cropBoundsDidChange: Bool {
        return self.cropBounds.value != self.initialCropBounds
    }

    var sortOrderDidChange: Bool {
        return self.sortOrder.value != self.initialSortOrder
    }
}
