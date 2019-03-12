//
//  ImageStoreServiceMock.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 17.04.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

@testable import PhotoStickers
import UIKit

class ImageStoreServiceMock: ImageStoreServiceType {
    fileprivate var bundle: Bundle {
        return Bundle(for: type(of: self))
    }

    func storeImage(_: UIImage, forKey _: String, inCategory category: ImageCategory) -> URL? {
        return imageURL(forKey: "", inCategory: category)
    }

    func image(forKey _: String, inCategory category: ImageCategory) -> UIImage? {
        switch category {
        case .originals:
            return UIImage(named: "original.jpg", in: bundle, compatibleWith: nil)
        case .stickers:
            return UIImage(named: "sticker.png", in: bundle, compatibleWith: nil)
        }
    }

    func imageExists(forKey _: String, inCategory _: ImageCategory) -> Bool {
        return true
    }

    func imageURL(forKey _: String, inCategory category: ImageCategory) -> URL? {
        switch category {
        case .originals:
            return bundle.url(forResource: "original", withExtension: "jpg")
        case .stickers:
            return bundle.url(forResource: "sticker", withExtension: "png")
        }
    }

    func deleteImage(forKey _: String, inCategory _: ImageCategory) -> Bool {
        return true
    }
}
