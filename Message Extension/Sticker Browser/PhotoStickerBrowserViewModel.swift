//
//  PhotoStickerBrowserViewModel.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 30/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import RxRealm

protocol PhotoStickerBrowserViewModelType {
    var stickerService: StickerServiceType { get }
    var sectionItems: Observable<[StickerSectionItem]> { get }
    func openApp()
}

class PhotoStickerBrowserViewModel: BaseViewModel, PhotoStickerBrowserViewModelType {

    // MARK: Dependencies
    let extensionContext: NSExtensionContext?
    let stickerService: StickerServiceType

    // MARK: Output
    var sectionItems: Observable<[StickerSectionItem]>

    init(stickerService: StickerServiceType, extensionContext: NSExtensionContext?) {
        self.stickerService = stickerService
        self.extensionContext = extensionContext

        let predicate = NSPredicate(format: "renderedStickerFilePath != nil")
        self.sectionItems = stickerService
            .fetchStickers(withPredicate: predicate)
            .map { allStickers in
                var items = allStickers.map { sticker in
                    return StickerSectionItem.StickerItem(sticker: sticker)
                }
                items.append(StickerSectionItem.OpenAppItem)
                return items
            }

        super.init()
    }

    func openApp() {
        if let url = URL(string: "photosticker://create") {
            self.extensionContext?.open(url, completionHandler: nil)
        }
    }
}
