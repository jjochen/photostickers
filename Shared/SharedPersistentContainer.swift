//
//  SharedPersistentContainer.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 01/01/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import CoreData

final class SharedPersistentContainer: NSPersistentContainer {
    internal override class func defaultDirectoryURL() -> URL {
        var url = super.defaultDirectoryURL()
        if let newURL = AppGroup.documentsURL {
            url = newURL
        }
        return url
    }
}
