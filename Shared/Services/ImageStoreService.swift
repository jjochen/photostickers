//
//  ImageStore.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 03/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit
import Log

protocol ImageStoreServiceType {
    func storeImage(_ image: UIImage!, forKey key: String!, inCategory category: String!) -> URL?
    func image(forKey key: String!, inCategory category: String!) -> UIImage?
    func imageExists(forKey key: String!, inCategory category: String!) -> Bool
    func imageURL(forKey key: String!, inCategory category: String!) -> URL?
}

class ImageStoreService: BaseService, ImageStoreServiceType {

    fileprivate let storeURL: URL?

    init(provider: ServiceProviderType, url: URL?) {
        self.storeURL = url
        super.init(provider: provider)
    }
}

extension ImageStoreService {

    func storeImage(_ image: UIImage!, forKey key: String!, inCategory category: String!) -> URL? {
        guard let data = UIImagePNGRepresentation(image) else {
            Logger.shared.error("PNG representation not possible: \(image)")
            return nil
        }

        guard let url = self.constructImageURL(forKey: key, inCategory: category) else {
            Logger.shared.error("No image url for key \(key) in category \(category)")
            return nil
        }

        if !self.createSubfolderForCategory(category) {
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

    func image(forKey key: String!, inCategory category: String!) -> UIImage? {
        guard let url = self.constructImageURL(forKey: key, inCategory: category) else {
            Logger.shared.error("No image url for key \(key) in category \(category)")
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }

    func imageExists(forKey key: String!, inCategory category: String!) -> Bool {
        guard let url = self.constructImageURL(forKey: key, inCategory: category) else {
            Logger.shared.error("No image url for key \(key) in category \(category)")
            return false
        }
        return FileManager.default.fileExists(atPath: url.path)
    }

    func imageURL(forKey key: String!, inCategory category: String!) -> URL? {
        guard self.imageExists(forKey: key, inCategory: category) else {
            return nil
        }
        return self.constructImageURL(forKey: key, inCategory: category)
    }
}

extension ImageStoreService {

    fileprivate func createSubfolderForCategory(_ category: String!) -> Bool {
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

    fileprivate func constructCategoryURL(_ category: String!) -> URL? {
        return self.storeURL?.appendingPathComponent(category, isDirectory: true)
    }

    fileprivate func constructImageURL(forKey key: String!, inCategory category: String!) -> URL? {
        return self.constructCategoryURL(category)?.appendingPathComponent(key).appendingPathExtension("png")
    }
}
