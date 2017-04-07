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
}

class StickerCollectionCellModel: BaseViewModel, StickerCollectionCellModelType {
    let sticker: Sticker

    init(_ sticker: Sticker) {
        self.sticker = sticker
        super.init()
    }
}
