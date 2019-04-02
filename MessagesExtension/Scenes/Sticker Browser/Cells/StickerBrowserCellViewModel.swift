//
//  StickerBrowserCellModel.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 14.04.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Log
import Messages
import RxCocoa
import RxSwift
import UIKit

protocol StickerBrowserCellViewModelType: AnyObject {
    var sticker: Sticker { get }
    var msSticker: MSSticker? { get }
    var image: UIImage? { get }
    var placeholderHidden: Bool { get }
    var shake: Driver<Bool> { get }
    var hideDeleteButton: Driver<Bool> { get }
    var hideSticker: Driver<Bool> { get }
    var hideImageView: Driver<Bool> { get }
}

class StickerBrowserCellViewModel: BaseViewModel, StickerBrowserCellViewModelType {
    let sticker: Sticker
    let msSticker: MSSticker?
    let image: UIImage?
    let placeholderHidden: Bool
    let isEditing: Driver<Bool>

    var shake: Driver<Bool>
    var hideDeleteButton: Driver<Bool>
    var hideSticker: Driver<Bool>
    var hideImageView: Driver<Bool>

    init(sticker: Sticker, editing: Driver<Bool>, imageStore: ImageStoreServiceType) {
        self.sticker = sticker
        isEditing = editing

        let imageURL = sticker.renderedImageURL(in: imageStore)
        let title = sticker.title
        msSticker = StickerBrowserCellViewModel.msSticker(imageURL: imageURL, title: title)
        placeholderHidden = msSticker != nil

        image = sticker.renderedImage(from: imageStore)

        shake = isEditing
        hideDeleteButton = isEditing.map { !$0 }
        hideSticker = isEditing
        hideImageView = isEditing.map { !$0 }

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
