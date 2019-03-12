//
//  StickerCollectionCellViewModel.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 08/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit

protocol StickerCollectionCellModelType: class {
    var sticker: Sticker { get }
    var image: UIImage? { get }
    var placeholderHidden: Bool { get }
}

class StickerCollectionCellModel: BaseViewModel, StickerCollectionCellModelType {
    let sticker: Sticker
    let image: UIImage?
    let placeholderHidden: Bool

    init(sticker: Sticker, imageStoreService: ImageStoreServiceType) {
        self.sticker = sticker
        image = sticker.renderedImage(from: imageStoreService)
        placeholderHidden = image != nil

        super.init()
    }
}
