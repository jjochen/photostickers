//
//  ImageStore.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 03/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import UIKit
import Log

struct ImageStore {

    static func storeImage(_ image: UIImage!, forKey key: String!, inCategory category: String!) -> Bool {
        guard let data = UIImagePNGRepresentation(image) else {
            Logger.shared.error("PNG representation not possible: \(image)")
            return false
        }

        guard let url = self.constructImageURL(forKey: key, inCategory: category) else {
            Logger.shared.error("No image url for key \(key) in category \(category)")
            return false
        }

        if !self.createSubfolderForCategory(category) {
            Logger.shared.error("Could not create subfolder for category \(category)")
            return false
        }

        var success = false
        do {
            try data.write(to: url, options: .atomic)
            success = true
        } catch {
            Logger.shared.error(error)
        }
        return success
    }

    static func image(forKey key: String!, inCategory category: String!) -> UIImage? {
        guard let url = self.constructImageURL(forKey: key, inCategory: category) else {
            Logger.shared.error("No image url for key \(key) in category \(category)")
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }

    static func imageExists(forKey key: String!, inCategory category: String!) -> Bool {
        guard let url = self.constructImageURL(forKey: key, inCategory: category) else {
            Logger.shared.error("No image url for key \(key) in category \(category)")
            return false
        }
        return FileManager.default.fileExists(atPath: url.path)
    }

    static func imageURL(forKey key: String!, inCategory category: String!) -> URL? {
        guard self.imageExists(forKey: key, inCategory: category) else {
            return nil
        }
        return self.constructImageURL(forKey: key, inCategory: category)
    }
}

extension ImageStore {

    fileprivate static func createSubfolderForCategory(_ category: String!) -> Bool {
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

    fileprivate static func constructCategoryURL(_ category: String!) -> URL? {
        return AppGroup.documentsURL?.appendingPathComponent(category, isDirectory: true)
    }

    fileprivate static func constructImageURL(forKey key: String!, inCategory category: String!) -> URL? {
        return self.constructCategoryURL(category)?.appendingPathComponent(key).appendingPathExtension("png")
    }
}
