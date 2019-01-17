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
    case title
    case hasOriginalImage
    case hasRenderedImage
    case cropBoundsX
    case cropBoundsY
    case cropBoundsWidth
    case cropBoundsHeight
    case maskType
    case sortOrder
}

// MARK: Realm Object

class Sticker: Object {
    @objc dynamic var uuid = ""
    @objc dynamic var title: String?
    @objc dynamic var hasOriginalImage: Bool = false
    @objc dynamic var hasRenderedImage: Bool = false
    @objc dynamic var cropBoundsX: Double = 0
    @objc dynamic var cropBoundsY: Double = 0
    @objc dynamic var cropBoundsWidth: Double = 0
    @objc dynamic var cropBoundsHeight: Double = 0
    @objc dynamic var maskType: Int = Mask.circle.rawValue
    @objc dynamic var sortOrder = 0

    override static func primaryKey() -> String? {
        return StickerProperty.uuid.rawValue
    }

    override static func indexedProperties() -> [String] {
        return [StickerProperty.sortOrder.rawValue]
    }

    override static func ignoredProperties() -> [String] {
        return ["cropBounds"]
    }

    static func newSticker() -> Sticker {
        let sticker = Sticker()
        sticker.uuid = UUID().uuidString
        return sticker
    }
}

// MARK: Equitable

func == (lhs: Sticker, rhs: Sticker) -> Bool {
    return lhs.uuid == rhs.uuid
}

extension Sticker {
    static let renderedSize = CGSize(width: 300, height: 300)
    static let titlePlaceholder = "Photo Sticker"
}

// MARK: Bounds

extension Sticker {
    var cropBounds: CGRect {
        get {
            return CGRect(x: cropBoundsX, y: cropBoundsY, width: cropBoundsWidth, height: cropBoundsHeight)
        }
        set(bounds) {
            cropBoundsX = Double(bounds.origin.x)
            cropBoundsY = Double(bounds.origin.y)
            cropBoundsWidth = Double(bounds.size.width)
            cropBoundsHeight = Double(bounds.size.height)
        }
    }
}

// MARK: Mask

extension Sticker {
    var mask: Mask {
        get {
            return Mask(rawValue: maskType) ?? .circle
        }
        set(mask) {
            maskType = mask.rawValue
        }
    }
}

// MARK: RxDataSource Methods

extension Sticker: IdentifiableType {
    typealias Identity = String

    var identity: Identity { return uuid }
}
