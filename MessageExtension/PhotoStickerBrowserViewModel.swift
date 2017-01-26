//
//  PhotoStickerBrowserViewModel.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 30/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RealmSwift
import RxRealm

protocol PhotoStickerBrowserViewModelType {
    var realmContext: Realm! { get }
    var sectionItems: Observable<[StickerSectionItem]> { get }
    func openApp()
}

class PhotoStickerBrowserViewModel: ViewModel, PhotoStickerBrowserViewModelType {

    // MARK: - Input

    let extensionContext: NSExtensionContext?
    let realmContext: Realm!

    // MARK: - Output

    var sectionItems: Observable<[StickerSectionItem]>

    init(extensionContext: NSExtensionContext?, realmContext: Realm!) {
        self.extensionContext = extensionContext
        self.realmContext = realmContext

        let stickers = self.realmContext.objects(Sticker.self)

        self.sectionItems = Observable
            .array(from: stickers)
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
        if let url = URL(string: "photosticker://open") {
            self.extensionContext?.open(url, completionHandler: nil)
        }
    }
}
