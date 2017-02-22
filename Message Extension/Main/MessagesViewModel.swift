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
    var extensionContext: NSExtensionContext? { get }
    var stickerService: StickerServiceType { get }
    func photoStickerBrowserViewModel() -> PhotoStickerBrowserViewModelType
}

class MessagesViewModel: BaseViewModel, MessagesViewModelType {

    let extensionContext: NSExtensionContext?
    let stickerService: StickerServiceType

    init(stickerService: StickerServiceType, extensionContext: NSExtensionContext?) {
        self.stickerService = stickerService
        self.extensionContext = extensionContext
        super.init()
    }

    // MARK: - View Models

    func photoStickerBrowserViewModel() -> PhotoStickerBrowserViewModelType {
        return PhotoStickerBrowserViewModel(stickerService: stickerService, extensionContext: extensionContext)
    }
}
