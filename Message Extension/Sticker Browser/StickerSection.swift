//
//  StickerSection.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 03/01/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import RxDataSources

struct StickerSection {
    var header: String

    var stickers: [StickerSectionItem]

    init(header: String, stickers: [StickerSectionItem]) {
        self.header = header
        self.stickers = stickers
    }
}

enum StickerSectionItem {
    case StickerItem(sticker: Sticker)
    case OpenAppItem
}

extension StickerSection: SectionModelType {
    typealias Item = StickerSectionItem
    typealias Identity = String

    var identity: String {
        return header
    }

    var items: [StickerSectionItem] {
        return stickers
    }

    init(original: StickerSection, items: [Item]) {
        self = original
        stickers = items
    }
}

extension StickerSectionItem: IdentifiableType, Equatable {
    typealias Identity = String

    var identity: String {
        switch self {
        case .OpenAppItem:
            return "OpenAppItem"
        case let .StickerItem(sticker: sticker):
            return sticker.uuid
        }
    }
}

// equatable, this is needed to detect changes
func == (lhs: StickerSectionItem, rhs: StickerSectionItem) -> Bool {
    return lhs.identity == rhs.identity
}
