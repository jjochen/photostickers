//
//  StickerBrowserCellModel.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 14.04.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit
import Messages
import Log

protocol StickerBrowserCellViewModelType: class {
    var sticker: Sticker { get }
    var msSticker: MSSticker? { get }
    var placeholderHidden: Bool { get }
}

class StickerBrowserCellViewModel: BaseViewModel, StickerBrowserCellViewModelType {

    let sticker: Sticker
    let msSticker: MSSticker?
    let placeholderHidden: Bool

    init(sticker: Sticker, imageStore: ImageStoreServiceType) {
        self.sticker = sticker

        let imageURL = sticker.renderedImageURL(in: imageStore)
        let title = sticker.title

        msSticker = StickerBrowserCellViewModel.msSticker(imageURL: imageURL, title: title)
        placeholderHidden = msSticker != nil

        super.init()
    }

    fileprivate static func msSticker(imageURL: URL?, title: String?) -> MSSticker? {
        guard let url = imageURL else {
            Logger.shared.error("Couldn't create a sticker from url: nil")
            return nil
        }
        let description = title ?? Sticker.titlePlaceholder

        var msSticker: MSSticker?
        do {
            try msSticker = MSSticker(contentsOfFileURL: url, localizedDescription: description)
        } catch {
            Logger.shared.error(error)
        }
        return msSticker
    }
}
