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

enum StickerProperty: String {
    case uuid
    case localizedDescription
    case originalImageFilePath
    case renderedStickerFilePath
    case cropBoundsX
    case cropBoundsY
    case cropBoundsWidth
    case cropBoundsHeight
    case sortOrder
}

// MARK: Realm Object
class Sticker: Object {
    dynamic var uuid = ""
    dynamic var localizedDescription = ""
    dynamic var originalImageFilePath: String?
    dynamic var renderedStickerFilePath: String?
    dynamic var cropBoundsX: Double = 0
    dynamic var cropBoundsY: Double = 0
    dynamic var cropBoundsWidth: Double = 0
    dynamic var cropBoundsHeight: Double = 0
    dynamic var sortOrder = 0

    override static func primaryKey() -> String? {
        return StickerProperty.uuid.rawValue
    }

    override static func indexedProperties() -> [String] {
        return [StickerProperty.sortOrder.rawValue]
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

// MARK: Images
extension Sticker {

    var originalImage: UIImage? {
        guard let path = self.originalImageFilePath else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }

    var renderedSticker: UIImage? {
        guard let path = self.renderedStickerFilePath else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }

    var renderedStickerURL: URL? {
        guard let path = self.renderedStickerFilePath else {
            return nil
        }
        return URL(fileURLWithPath: path)
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
