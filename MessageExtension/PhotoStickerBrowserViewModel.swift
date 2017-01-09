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
import CoreData

protocol PhotoStickerBrowserViewModelType {
    var managedObjectContext: NSManagedObjectContext { get }
    var sectionItems: Observable<[StickerSectionItem]> { get }
    func openApp()
}

class PhotoStickerBrowserViewModel: ViewModel, PhotoStickerBrowserViewModelType {

    // MARK: - Input

    let extensionContext: NSExtensionContext?
    let managedObjectContext: NSManagedObjectContext

    // MARK: - Output

    var sectionItems: Observable<[StickerSectionItem]>

    init(extensionContext: NSExtensionContext?, managedObjectContext: NSManagedObjectContext) {
        self.extensionContext = extensionContext
        self.managedObjectContext = managedObjectContext

        self.sectionItems = managedObjectContext.rx
            .entities(Sticker.self, sortDescriptors: [
                NSSortDescriptor(key: "sortOrder", ascending: true),
                NSSortDescriptor(key: "stickerDescription", ascending: true),
            ])
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
