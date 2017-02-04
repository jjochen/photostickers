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

    static func storeImage(_ image: UIImage!, forKey key: String!, inCategory category: String!) -> URL? {
        guard let data = UIImagePNGRepresentation(image) else {
            return nil
        }

        guard let url = self.imageURL(forKey: key, inCategory: category) else {
            return nil
        }

        if !self.createSubfolderForCategory(category) {
            return nil
        }

        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            Logger.shared.error(error)
            return nil
        }
    }

    static func image(forKey key: String!, inCategory category: String!) -> UIImage? {
        guard let url = self.imageURL(forKey: key, inCategory: category) else {
            return nil
        }
        return UIImage(contentsOfFile: url.absoluteString)
    }

    fileprivate static func createSubfolderForCategory(_ category: String!) -> Bool {
        guard let url = self.categoryURL(category) else {
            return false
        }

        let fileManager = FileManager.default

        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            Logger.shared.error(error)
            return false
        }
    }

    fileprivate static func categoryURL(_ category: String!) -> URL? {
        return AppGroup.documentsURL?.appendingPathComponent(category, isDirectory: true)
    }

    fileprivate static func imageURL(forKey key: String!, inCategory category: String!) -> URL? {
        return self.categoryURL(category)?.appendingPathComponent(key).appendingPathExtension("png")
    }
}
