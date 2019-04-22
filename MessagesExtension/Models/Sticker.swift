//
//  Sticker+CoreDataClass.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 01/01/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import RealmSwift
import RxDataSources
import UIKit

enum StickerProperty: String {
    case uuid
    case title
    case originalImageFilePath
    case renderedImageFilePath
    case renderedImageVersion
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
    @objc dynamic var originalImageFilePath: String?
    @objc dynamic var renderedImageFilePath: String?
    @objc dynamic var renderedImageVersion: Int = 0
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

// MARK: Images

extension Sticker {
    var originalImage: UIImage? {
        guard let filePath = originalImageFilePath else {
            return nil
        }
        return UIImage(contentsOfFile: filePath)
    }

    var renderedImage: UIImage? {
        guard let filePath = renderedImageFilePath else {
            return nil
        }
        return UIImage(contentsOfFile: filePath)
    }

    var originalImageURL: URL? {
        guard let path = originalImageFilePath else {
            return nil
        }
        return URL(fileURLWithPath: path)
    }

    var renderedImageURL: URL? {
        guard let path = renderedImageFilePath else {
            return nil
        }
        return URL(fileURLWithPath: path)
    }

    var hasOriginalImage: Bool {
        guard let path = originalImageFilePath else {
            return false
        }
        return FileManager.default.fileExists(atPath: path)
    }

    var hasRenderedImage: Bool {
        guard let path = renderedImageFilePath else {
            return false
        }
        return FileManager.default.fileExists(atPath: path)
    }

    func deleteOriginalImage() {
        guard let path = originalImageFilePath else {
            return
        }
        try? FileManager.default.removeItem(atPath: path)
    }

    func deleteRenderedImage() {
        guard let path = renderedImageFilePath else {
            return
        }
        try? FileManager.default.removeItem(atPath: path)
    }
}

// MARK: RxDataSource Methods

extension Sticker: IdentifiableType {
    typealias Identity = String

    var identity: Identity { return uuid }
}
