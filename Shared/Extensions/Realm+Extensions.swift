//
//  Realm+Extensions.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 26/01/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import RealmSwift
import Log

extension Realm {
    static func configureForAppGroup() {
        var config = Realm.Configuration()
        guard let appGroupDirectory = AppGroup.documentsURL else {
            Logger.shared.error("No app group directory")
            return
        }
        let realmPath = appGroupDirectory.appendingPathComponent("photo-stickers.realm")
        config.fileURL = realmPath
        Realm.Configuration.defaultConfiguration = config
        #if DEBUG
            do {
                try _ = Realm()
            } catch {
                Logger.shared.error(error, "Will reset app!")
                try! FileManager.default.removeItem(at: appGroupDirectory)
                fatalError("Restart needed after reset")
            }
        #endif
    }
}
