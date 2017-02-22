//
//  MessagesViewModel.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 30/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import RealmSwift

class MessagesViewModel: BaseViewModel {

    var extensionContext: NSExtensionContext?
    var stickerService: StickerServiceType

    init(stickerService: StickerServiceType, extensionContext: NSExtensionContext?) {
        self.stickerService = stickerService
        self.extensionContext = extensionContext
        super.init()
    }

    // MARK: - View Models

    func photoStickerBrowserViewModel() -> PhotoStickerBrowserViewModel {
        return PhotoStickerBrowserViewModel(stickerService: stickerService, extensionContext: extensionContext)
    }
}
