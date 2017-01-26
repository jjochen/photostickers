//
//  Realm+Extensions.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 26/01/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import RealmSwift

extension Realm {
    static func configureForAppGroup() {
        var config = Realm.Configuration()
        if let newURL = AppGroup.documentsURL {
            config.fileURL = newURL.appendingPathComponent("photo-stickers.realm")
        }
        Realm.Configuration.defaultConfiguration = config
    }
}
