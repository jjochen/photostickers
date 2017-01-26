//
//  Sticker+CoreDataClass.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 01/01/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import RealmSwift
import Messages
import Log

class Sticker: Object {
    dynamic var uuid = ""
    dynamic var stickerPath: String?
    dynamic var stickerDescription: String?
    dynamic var sortOrder = 0
}

extension Sticker {
    override static func primaryKey() -> String? {
        return "uuid"
    }

    override static func indexedProperties() -> [String] {
        return ["sortOrder"]
    }

    override static func ignoredProperties() -> [String] {
        return []
    }
}

extension Sticker {
    public var localizedDescription: String! {
        guard let localizedDescription = self.stickerDescription else {
            return "Sticker"
        }
        return localizedDescription
    }

    public var stickerURL: URL? {
        guard let filePath = stickerPath else {
            return nil
        }
        let stickerURL = URL(string: filePath)
        return stickerURL
    }
}

extension Sticker {
    public func loadMSSticker() -> MSSticker? {
        let stickerURL: URL? = self.stickerURL
        let localizedDescription: String! = self.localizedDescription
        guard stickerURL != nil else {
            return nil
        }
        let sticker: MSSticker
        do {
            try sticker = MSSticker(contentsOfFileURL: stickerURL!, localizedDescription: localizedDescription)
        } catch {
            Logger.shared.error(error)
            return nil
        }
        return sticker
    }
}
