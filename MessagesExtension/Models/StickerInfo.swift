//
//  StickerInfo.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 24/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class StickerInfo {
    let uuid: String

    // MARK: initial values

    let initialTitle: String?
    let initialOriginalImage: UIImage?
    let initialRenderedSticker: UIImage?
    let initialCropBounds: CGRect
    let initialMask: Mask
    let initialSortOrder: Int

    // MARK: updated values

    let title: BehaviorRelay<String?>
    let originalImage: BehaviorRelay<UIImage?>
    let renderedSticker: BehaviorRelay<UIImage?>
    let cropBounds: BehaviorRelay<CGRect>
    let mask: BehaviorRelay<Mask>
    let sortOrder: BehaviorRelay<Int>

    // MARK: initilizer

    init(uuid: String,
         title: String?,
         originalImage: UIImage?,
         renderedSticker: UIImage?,
         cropBounds: CGRect,
         mask: Mask,
         sortOrder: Int) {
        self.uuid = uuid

        initialTitle = title
        initialOriginalImage = originalImage
        initialRenderedSticker = renderedSticker
        initialCropBounds = cropBounds
        initialMask = mask
        initialSortOrder = sortOrder

        self.title = BehaviorRelay(value: title)
        self.originalImage = BehaviorRelay(value: originalImage)
        self.renderedSticker = BehaviorRelay(value: renderedSticker)
        self.cropBounds = BehaviorRelay(value: cropBounds)
        self.mask = BehaviorRelay(value: mask)
        self.sortOrder = BehaviorRelay(value: sortOrder)
    }

    convenience init() {
        self.init(uuid: "",
                  title: nil,
                  originalImage: nil,
                  renderedSticker: nil,
                  cropBounds: CGRect.zero,
                  mask: Mask.circle,
                  sortOrder: 0)
    }

    // MARK: Observers

    var originalImageIsNil: Observable<Bool> {
        return originalImage
            .asObservable()
            .map { $0 == nil }
    }

    var renderedStickerIsNil: Observable<Bool> {
        return renderedSticker
            .asObservable()
            .map { $0 == nil }
    }

    var cropBoundsAreEmpty: Observable<Bool> {
        return cropBounds
            .asObservable()
            .map { $0.isNull || $0.isEmpty }
    }

    // MARK: canges

    var titleDidChange: Bool {
        return title.value != initialTitle
    }

    var originalImageDidChange: Bool {
        return originalImage.value != initialOriginalImage
    }

    var renderedStickerDidChange: Bool {
        return renderedSticker.value != initialRenderedSticker
    }

    var cropBoundsDidChange: Bool {
        return cropBounds.value != initialCropBounds
    }

    var maskDidChange: Bool {
        return mask.value != initialMask
    }

    var sortOrderDidChange: Bool {
        return sortOrder.value != initialSortOrder
    }
}
