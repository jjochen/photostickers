//
//  MessageApp.swift
//  PhotoStickers
//
//  Created by Jochen on 29.03.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import Foundation

// todo: move?
protocol HasExtensionContext {
    var extensionContext: NSExtensionContext { get }
}

final class Application {
    fileprivate let extensionContext: NSExtensionContext
    fileprivate let stickerService: StickerService
    fileprivate let imageStoreService: ImageStoreService
    fileprivate let stickerRenderService: StickerRenderService

    init(extensionContext: NSExtensionContext) {
        #if DEBUG
        // todo
        let dataFolderType = DataFolderType.appGroupPrefilled(subfolder: "UITests")
        #else
        let dataFolderType = DataFolderType.appGroup
        #endif
        let dataFolder = DataFolderService(type: dataFolderType)

        self.extensionContext = extensionContext
        self.imageStoreService = ImageStoreService(url: dataFolder.imagesURL)
        self.stickerService = StickerService(realmType: .onDisk(url: dataFolder.realmURL), imageStoreService: imageStoreService)
        self.stickerRenderService = StickerRenderService()
    }

    lazy var appServices = {
        AppServices(extensionContext: self.extensionContext, stickerService: self.stickerService, imageStoreService: self.imageStoreService, stickerRenderService: self.stickerRenderService)
    }()
}

struct AppServices: HasExtensionContext, HasStickerService, HasImageStoreService, HasStickerRenderService {
    let extensionContext: NSExtensionContext
    let stickerService: StickerService
    let imageStoreService: ImageStoreService
    let stickerRenderService: StickerRenderService
}
