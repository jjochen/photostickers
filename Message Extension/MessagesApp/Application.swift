//
//  MessageApp.swift
//  PhotoStickers
//
//  Created by Jochen on 29.03.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import Foundation

final class Application {

    fileprivate let extensionContext: NSExtensionContext?
    fileprivate let stickerService: StickerServiceType
    fileprivate let imageStoreService: ImageStoreServiceType
    fileprivate let stickerRenderService: StickerRenderServiceType

    init(extensionContext: NSExtensionContext?) {
        #if DEBUG
        let isRunningUITests = true
        #else
        // TODO:
        let isRunningUITests = UserDefaults.standard.bool(forKey: "RunningUITests")
        #endif
        let dataFolderType: DataFolderType = isRunningUITests ? .appGroupPrefilled(subfolder: "UITests") : .appGroup
        let dataFolder: DataFolderServiceType = DataFolderService(type: dataFolderType)

        self.extensionContext = extensionContext
        self.imageStoreService = ImageStoreService(url: dataFolder.imagesURL)
        self.stickerService = StickerService(realmType: .onDisk(url: dataFolder.realmURL), imageStoreService: imageStoreService)
        self.stickerRenderService = StickerRenderService()
    }

    

}
