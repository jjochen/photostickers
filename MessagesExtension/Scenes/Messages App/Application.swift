//
//  MessageApp.swift
//  PhotoStickers
//
//  Created by Jochen on 29.03.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import Foundation

final class Application {
    private let stickerService: StickerService
    private let imageStoreService: ImageStoreService
    private let stickerRenderService: StickerRenderService

    init() {
        #if DEBUG
            // todo
            let dataFolderType = DataFolderType.documentsPrefilled(subfolder: "UITests")
        #else
            let dataFolderType = DataFolderType.appGroup
        #endif
        let dataFolder = DataFolderService(type: dataFolderType)

        imageStoreService = ImageStoreService(url: dataFolder.imagesURL)
        stickerService = StickerService(realmType: .onDisk(url: dataFolder.realmURL), imageStoreService: imageStoreService)
        stickerRenderService = StickerRenderService()
    }

    lazy var appServices = {
        AppServices(stickerService: self.stickerService, imageStoreService: self.imageStoreService, stickerRenderService: self.stickerRenderService)
    }()
}

struct AppServices: HasStickerService, HasImageStoreService, HasStickerRenderService {
    let stickerService: StickerService
    let imageStoreService: ImageStoreService
    let stickerRenderService: StickerRenderService
}
