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
    dynamic var localizedDescription = ""
    dynamic var hasRenderedSticker = false
    dynamic var cropBoundsX: Double = 0
    dynamic var cropBoundsY: Double = 0
    dynamic var cropBoundsWidth: Double = 0
    dynamic var cropBoundsHeight: Double = 0
    dynamic var sortOrder = 0

    override static func primaryKey() -> String? {
        return "uuid"
    }

    override static func indexedProperties() -> [String] {
        return ["sortOrder"]
    }

    override static func ignoredProperties() -> [String] {
        return ["renderedSticker", "originalImage", "cropBounds"]
    }
}

// MARK: Equitable
func == (lhs: Sticker, rhs: Sticker) -> Bool {
    return lhs.uuid == rhs.uuid
}

extension Sticker {
    static let renderedSize = CGSize(width: 300, height: 300)
}

// MARK: Image Storage
extension Sticker {

    private static let renderedStickerCategory = "stickers"

    var renderedSticker: UIImage? {
        get {
            return ImageStore.image(forKey: self.uuid, inCategory: Sticker.renderedStickerCategory)
        }
        set(image) {
            let success = ImageStore.storeImage(image, forKey: self.uuid, inCategory: Sticker.renderedStickerCategory)
            self.hasRenderedSticker = success || self.hasStoredRenderedSticker
        }
    }

    var renderedStickerURL: URL? {
        return ImageStore.imageURL(forKey: self.uuid, inCategory: Sticker.renderedStickerCategory)
    }

    var hasStoredRenderedSticker: Bool {
        return ImageStore.imageExists(forKey: self.uuid, inCategory: Sticker.renderedStickerCategory)
    }

    private static let originalImageCategory = "originals"

    var originalImage: UIImage? {
        get {
            return ImageStore.image(forKey: self.uuid, inCategory: Sticker.originalImageCategory)
        }
        set(image) {
            _ = ImageStore.storeImage(image, forKey: self.uuid, inCategory: Sticker.originalImageCategory)
        }
    }

    var originalImageURL: URL? {
        return ImageStore.imageURL(forKey: self.uuid, inCategory: Sticker.originalImageCategory)
    }

    var hasStoredOriginalImage: Bool {
        return ImageStore.imageExists(forKey: self.uuid, inCategory: Sticker.originalImageCategory)
    }
}

// MARK: Bounds
extension Sticker {

    var cropBounds: CGRect {
        get {
            return CGRect(x: self.cropBoundsX, y: self.cropBoundsY, width: self.cropBoundsWidth, height: self.cropBoundsHeight)
        }
        set(bounds) {
            self.cropBoundsX = Double(bounds.origin.x)
            self.cropBoundsY = Double(bounds.origin.y)
            self.cropBoundsWidth = Double(bounds.size.width)
            self.cropBoundsHeight = Double(bounds.size.height)
        }
    }
}

// MARK: RxDataSource Methods
extension Sticker: IdentifiableType {
    typealias Identity = String

    var identity: Identity { return uuid }
}
