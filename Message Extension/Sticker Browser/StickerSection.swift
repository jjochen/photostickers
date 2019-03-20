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
    var stickers: [StickerSectionItem]

    init(stickers: [StickerSectionItem]) {
        self.stickers = stickers
    }
}

enum StickerSectionItem {
    case stickerItem(viewModel: StickerBrowserCellViewModelType)
    case openAppItem
}

extension StickerSection: SectionModelType {
    typealias Item = StickerSectionItem

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
        case .openAppItem:
            return "OpenAppItem"
        case let .stickerItem(viewModel: viewModel):
            return viewModel.sticker.uuid
        }
    }
}

// equatable, this is needed to detect changes
func == (lhs: StickerSectionItem, rhs: StickerSectionItem) -> Bool {
    return lhs.identity == rhs.identity
}
