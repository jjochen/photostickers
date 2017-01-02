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

    let managedObjectContext = CoreDataStack.shared.viewContext

    // MARK: - View Models

    func photoStickerBrowserViewModel() -> PhotoStickerBrowserViewModel {

        return PhotoStickerBrowserViewModel(managedObjectContext: self.managedObjectContext)
    }
}
