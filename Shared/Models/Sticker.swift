//
//  Sticker+CoreDataClass.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 01/01/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import RealmSwift
import RxDataSources

// MARK: Realm Object
class Sticker: Object {
    dynamic var uuid = ""
    dynamic var renderedStickerFilePath: String?
    dynamic var originalImageFilePath: String?
    dynamic var localizedDescription: String?
    dynamic var sortOrder = 0
}

// MARK: Equitable
func == (lhs: Sticker, rhs: Sticker) -> Bool {
    return lhs.uuid == rhs.uuid
}

extension Sticker {
    public var localizedDescriptionOrPlaceholder: String! {
        guard let description = self.localizedDescription else {
            return "Sticker"
        }
        return description
    }

    public var stickerURL: URL? {
        // ToDo
        self.renderSticker()

        guard let filePath = self.renderedStickerFilePath else {
            return nil
        }
        let stickerURL = URL(string: filePath)
        return stickerURL
    }

    private func renderSticker() {
        // ToDo

        self.renderedStickerFilePath = self.originalImageFilePath
    }
}

// MARK: Realm Specifications
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

// MARK: RxDataSource Methods
extension Sticker: IdentifiableType {
    typealias Identity = String

    var identity: Identity { return uuid }
}
