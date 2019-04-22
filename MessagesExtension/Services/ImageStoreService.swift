//
//  ImageStore.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 03/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit

private enum ImageCategory: String {
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

private enum ImageFileType: String {
    case jpg
    case png

    func data(for image: UIImage) -> Data? {
        switch self {
        case .png:
            return image.pngData()
        case .jpg:
            return image.jpegData(compressionQuality: 1.0)
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

protocol HasImageStoreService {
    var imageStoreService: ImageStoreService { get }
}

class ImageStoreService {
    private let storeURL: URL?

    init(url: URL?) {
        storeURL = url
    }

    func store(originalImage image: UIImage, forKey key: String) -> URL? {
        return storeImage(image, forKey: key, inCategory: .originals, version: nil)
    }

    func store(renderedImage image: UIImage, forKey key: String, version: Int) -> URL? {
        return storeImage(image, forKey: key, inCategory: .stickers, version: version)
    }

    func originalImageURL(forKey key: String) -> URL? {
        return constructImageURL(forKey: key, inCategory: .originals, version: nil)
    }

    func renderedImageURL(forKey key: String, version: Int?) -> URL? {
        return constructImageURL(forKey: key, inCategory: .stickers, version: version)
    }
}

private extension ImageStoreService {
    func storeImage(_ image: UIImage, forKey key: String, inCategory category: ImageCategory, version: Int?) -> URL? {
        guard let data = category.fileType.data(for: image) else {
            fatalErrorWhileDebugging("PNG/JPG representation not possible: \(image)")
            return nil
        }

        guard let url = self.constructImageURL(forKey: key, inCategory: category, version: version) else {
            fatalErrorWhileDebugging("No image url for key \(key) in category \(category)")
            return nil
        }

        if !createSubfolderForCategory(category) {
            fatalErrorWhileDebugging("Could not create subfolder for category \(category)")
            return nil
        }

        var result: URL?
        do {
            try data.write(to: url, options: .atomic)
            result = url
        } catch {
            fatalErrorWhileDebugging(error.localizedDescription)
        }
        return result
    }
}

private extension ImageStoreService {
    func createSubfolderForCategory(_ category: ImageCategory) -> Bool {
        guard let url = self.constructCategoryURL(category) else {
            fatalErrorWhileDebugging("No category url for \(category)")
            return false
        }

        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            fatalErrorWhileDebugging(error.localizedDescription)
            return false
        }
    }

    func constructCategoryURL(_ category: ImageCategory) -> URL? {
        return storeURL?.appendingPathComponent(category.subFolder, isDirectory: true)
    }

    func constructImageURL(forKey key: String, inCategory category: ImageCategory, version: Int?) -> URL? {
        let fileName = constructImageName(forKey: key, version: version)
        return constructCategoryURL(category)?
            .appendingPathComponent(fileName)
            .appendingPathExtension(category.fileType.fileExtension)
    }

    func constructImageName(forKey key: String, version: Int?) -> String {
        guard let version = version else {
            return key
        }
        return "\(key)_\(version)"
    }
}
