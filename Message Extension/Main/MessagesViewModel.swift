//
//  MessagesViewModel.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 30/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import RealmSwift

protocol MessagesViewModelType {
    func photoStickerBrowserViewModel() -> PhotoStickerBrowserViewModelType
}

class MessagesViewModel: BaseViewModel, MessagesViewModelType {

    let extensionContext: NSExtensionContext?
    let stickerService: StickerServiceType
    let imageStoreService: ImageStoreServiceType

    init(stickerService: StickerServiceType, imageStoreService: ImageStoreServiceType, extensionContext: NSExtensionContext?) {
        self.stickerService = stickerService
        self.imageStoreService = imageStoreService
        self.extensionContext = extensionContext
        super.init()
    }

    // MARK: - View Models

    func photoStickerBrowserViewModel() -> PhotoStickerBrowserViewModelType {
        return PhotoStickerBrowserViewModel(stickerService: stickerService, imageStoreService: imageStoreService, extensionContext: extensionContext)
    }
}
