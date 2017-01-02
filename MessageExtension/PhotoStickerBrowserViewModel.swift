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
    var stickers: Observable<[Sticker]> { get }
}

class PhotoStickerBrowserViewModel: ViewModel, PhotoStickerBrowserViewModelType {

    // MARK: - Input

    let managedObjectContext: NSManagedObjectContext

    // MARK: - Output

    var stickers: Observable<[Sticker]>

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext

        self.stickers = self.managedObjectContext.rx
            .entities(Sticker.self, sortDescriptors: [
                NSSortDescriptor(key: "sortOrder", ascending: true),
                NSSortDescriptor(key: "stickerDescription", ascending: true),
            ])

        super.init()
    }
}
