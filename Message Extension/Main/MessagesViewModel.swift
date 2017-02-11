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
    var realmContext: Realm!

    init(extensionContext: NSExtensionContext?, realmContext: Realm!) {
        self.extensionContext = extensionContext
        self.realmContext = realmContext
        super.init()
    }

    // MARK: - View Models

    func photoStickerBrowserViewModel() -> PhotoStickerBrowserViewModel {
        return PhotoStickerBrowserViewModel(extensionContext: self.extensionContext, realmContext: self.realmContext)
    }
}
