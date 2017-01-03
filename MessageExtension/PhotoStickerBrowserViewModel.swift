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
}

class PhotoStickerBrowserViewModel: ViewModel, PhotoStickerBrowserViewModelType {

    // MARK: - Input

    let managedObjectContext: NSManagedObjectContext

    // MARK: - Output

    var sectionItems: Observable<[StickerSectionItem]>

    init(managedObjectContext: NSManagedObjectContext) {
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
                items.insert(StickerSectionItem.OpenAppItem, at: 0)
                return items
            }

        super.init()
    }
}
