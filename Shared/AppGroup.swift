//
//  FileManagement.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 28/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Foundation

struct AppGroup {
    
    fileprivate static let appGroupID = "group.com.jochen-pfeiffer.photo-stickers"
    
    public static var userDefaults: UserDefaults? {
        let defaults = UserDefaults(suiteName: appGroupID)
        return defaults
    }
    
    public static var documentsURL: URL? {
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
        return url
    }
}
