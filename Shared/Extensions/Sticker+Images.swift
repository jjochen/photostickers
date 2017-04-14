//
//  Sticker+Images.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 14.04.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit

extension Sticker {

    func originalImage(from imageStoreService: ImageStoreServiceType) -> UIImage? {
        return imageStoreService.image(forKey: uuid, inCategory: .originals)
    }

    func renderedImage(from imageStoreService: ImageStoreServiceType) -> UIImage? {
        return imageStoreService.image(forKey: uuid, inCategory: .stickers)
    }

    func store(originalImage image: UIImage?, in imageStoreService: ImageStoreServiceType) -> URL? {
        guard let image = image else {
            return nil
        }
        return imageStoreService.storeImage(image, forKey: uuid, inCategory: .originals)
    }

    func store(renderedImage image: UIImage?, in imageStoreService: ImageStoreServiceType) -> URL? {
        guard let image = image else {
            return nil
        }
        return imageStoreService.storeImage(image, forKey: uuid, inCategory: .stickers)
    }

    func origianlImageURL(in imageStoreService: ImageStoreServiceType) -> URL? {
        return imageStoreService.imageURL(forKey: uuid, inCategory: .originals)
    }

    func renderedImageURL(in imageStoreService: ImageStoreServiceType) -> URL? {
        return imageStoreService.imageURL(forKey: uuid, inCategory: .stickers)
    }

    func hasOrigianlImage(in imageStoreService: ImageStoreServiceType) -> Bool {
        return imageStoreService.imageExists(forKey: uuid, inCategory: .originals)
    }

    func hasRenderedImage(in imageStoreService: ImageStoreServiceType) -> Bool {
        return imageStoreService.imageExists(forKey: uuid, inCategory: .stickers)
    }

    func deleteOrigianlImage(in imageStoreService: ImageStoreServiceType) -> Bool {
        return imageStoreService.deleteImage(forKey: uuid, inCategory: .originals)
    }

    func deleteRenderedImage(in imageStoreService: ImageStoreServiceType) -> Bool {
        return imageStoreService.deleteImage(forKey: uuid, inCategory: .stickers)
    }
}
