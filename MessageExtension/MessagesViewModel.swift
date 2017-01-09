//
//  MessagesViewModel.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 30/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import CoreData

class MessagesViewModel: ViewModel {

    var extensionContext: NSExtensionContext?
    var managedObjectContext: NSManagedObjectContext

    init(extensionContext: NSExtensionContext?, managedObjectContext: NSManagedObjectContext) {
        self.extensionContext = extensionContext
        self.managedObjectContext = managedObjectContext
        super.init()
    }

    // MARK: - View Models

    func photoStickerBrowserViewModel() -> PhotoStickerBrowserViewModel {
        return PhotoStickerBrowserViewModel(extensionContext: self.extensionContext, managedObjectContext: self.managedObjectContext)
    }
}
