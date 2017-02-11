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
    var provider: ServiceProviderType

    init(provider: ServiceProviderType, extensionContext: NSExtensionContext?) {
        self.provider = provider
        self.extensionContext = extensionContext
        super.init()
    }

    // MARK: - View Models

    func photoStickerBrowserViewModel() -> PhotoStickerBrowserViewModel {
        return PhotoStickerBrowserViewModel(provider: self.provider, extensionContext: self.extensionContext)
    }
}
