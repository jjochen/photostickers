//
//  StickerCollectionCellViewModel.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 08/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit

class StickerCollectionCellModel: ViewModel {
    let image: UIImage?
    init(_ sticker: Sticker) {
        image = sticker.renderedSticker
        super.init()
    }
}
