//
//  ImageStore.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 03/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Log
import UIKit

enum ImageCategory: String {
    case originals
    case stickers

    var fileType: ImageFileType {
        switch self {
        case .stickers:
            return .png
        case .originals:
            return .jpg
        }
    }

    var subFolder: String {
        return rawValue
    }
}

enum ImageFileType: String {
    case jpg
    case png

    func data(for image: UIImage) -> Data? {
        switch self {
        case .png:
            return UIImagePNGRepresentation(image)
        case .jpg:
            return UIImageJPEGRepresentation(image, 1.0)
        }
    }

    var fileExtension: String {
        switch self {
        case .png:
            return "png"
        case .jpg:
            return "jpg"
        }
    }
}

protocol ImageStoreServiceType {
    func storeImage(_ image: UIImage, forKey key: String, inCategory category: ImageCategory) -> URL?
    func image(forKey key: String, inCategory category: ImageCategory) -> UIImage?
    func imageExists(forKey key: String, inCategory category: ImageCategory) -> Bool
    func imageURL(forKey key: String, inCategory category: ImageCategory) -> URL?
    func deleteImage(forKey key: String, inCategory category: ImageCategory) -> Bool
}

class ImageStoreService: ImageStoreServiceType {
    fileprivate let storeURL: URL?

    init(url: URL?) {
        storeURL = url
    }
}

extension ImageStoreService {
    func storeImage(_ image: UIImage, forKey key: String, inCategory category: ImageCategory) -> URL? {
        guard let data = category.fileType.data(for: image) else {
            Logger.shared.error("PNG/JPG representation not possible: \(image)")
            return nil
        }

        guard let url = self.constructImageURL(forKey: key, inCategory: category) else {
            Logger.shared.error("No image url for key \(key) in category \(category)")
            return nil
        }

        if !createSubfolderForCategory(category) {
            Logger.shared.error("Could not create subfolder for category \(category)")
            return nil
        }

        var result: URL?
        do {
            try data.write(to: url, options: .atomic)
            result = url
        } catch {
            Logger.shared.error(error)
        }
        return result
    }

    func image(forKey key: String, inCategory category: ImageCategory) -> UIImage? {
        guard let url = self.constructImageURL(forKey: key, inCategory: category) else {
            Logger.shared.error("No image url for key \(key) in category \(category)")
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }

    func imageExists(forKey key: String, inCategory category: ImageCategory) -> Bool {
        guard let url = self.constructImageURL(forKey: key, inCategory: category) else {
            Logger.shared.error("No image url for key \(key) in category \(category)")
            return false
        }
        return FileManager.default.fileExists(atPath: url.path)
    }

    func imageURL(forKey key: String, inCategory category: ImageCategory) -> URL? {
        guard imageExists(forKey: key, inCategory: category) else {
            return nil
        }
        return constructImageURL(forKey: key, inCategory: category)
    }

    func deleteImage(forKey key: String, inCategory category: ImageCategory) -> Bool {
        guard let url = self.constructImageURL(forKey: key, inCategory: category) else {
            Logger.shared.error("No image url for key \(key) in category \(category)")
            return false
        }

        guard FileManager.default.fileExists(atPath: url.path) else {
            Logger.shared.warning("No image at url \(url)")
            return false
        }

        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            Logger.shared.error(error)
            return false
        }

        return true
    }
}

fileprivate extension ImageStoreService {
    func createSubfolderForCategory(_ category: ImageCategory) -> Bool {
        guard let url = self.constructCategoryURL(category) else {
            Logger.shared.error("No category url for \(category)")
            return false
        }

        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            Logger.shared.error(error)
            return false
        }
    }

    func constructCategoryURL(_ category: ImageCategory) -> URL? {
        return storeURL?.appendingPathComponent(category.subFolder, isDirectory: true)
    }

    func constructImageURL(forKey key: String, inCategory category: ImageCategory) -> URL? {
        return constructCategoryURL(category)?.appendingPathComponent(key).appendingPathExtension(category.fileType.fileExtension)
    }
}
