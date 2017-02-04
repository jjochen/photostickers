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
    dynamic var localizedDescription = ""
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
    static let stickersSubfolder = "stickers"
    static let originalsSubfolder = "originals"
}

extension Sticker {
    var renderedStickerURL: URL? {
        guard let path = self.renderedStickerFilePath else {
            return nil
        }
        let url = URL(string: path)
        return url
    }

    var originalImageURL: URL? {
        guard let path = self.originalImageFilePath else {
            return nil
        }
        let url = URL(string: path)
        return url
    }

    var renderedSticker: UIImage? {
        get {
            guard let path = self.renderedStickerFilePath else {
                return nil
            }
            let image = UIImage(contentsOfFile: path)
            return image
        }
        set(image) {
            self.renderedStickerFilePath = ImageStore.storeImage(image, forKey: self.uuid, inCategory: Sticker.stickersSubfolder)?.absoluteString
        }
    }

    var originalImage: UIImage? {
        get {
            guard let path = self.originalImageFilePath else {
                return nil
            }
            let image = UIImage(contentsOfFile: path)
            return image
        }
        set(image) {
            self.originalImageFilePath = ImageStore.storeImage(image, forKey: self.uuid, inCategory: Sticker.originalsSubfolder)?.absoluteString
        }
    }

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
