//
//  FileManagement.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 28/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Foundation

enum DataFolderType {
    case appGroup
    case temporary
}

protocol DataFolderServiceType {
    var url: URL? { get }
    var userDefaults: UserDefaults? { get }
    var imagesURL: URL? { get }
    var realmURL: URL? { get }
}

struct DataFolderService: DataFolderServiceType {

    fileprivate let appGroupID = "group.com.jochen-pfeiffer.photo-stickers"

    fileprivate let type: DataFolderType
    var url: URL?

    init(type: DataFolderType = .appGroup) {
        self.type = type
        switch type {
        case .appGroup:
            url = appGroupFolderURL()
            break
        case .temporary:
            url = createTempDirectory()
            break
        }
    }

    var userDefaults: UserDefaults? {
        let defaults = UserDefaults(suiteName: appGroupID)
        return defaults
    }

    var imagesURL: URL? {
        let url = self.url?.appendingPathComponent("images")
        return url
    }

    var realmURL: URL? {
        let url = self.url?.appendingPathComponent("stickers.realm")
        return url
    }

    fileprivate func appGroupFolderURL() -> URL? {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }

    fileprivate func createTempDirectory() -> URL? {
        guard let tempDirURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString) else {
            return nil
        }

        do {
            try FileManager.default.createDirectory(at: tempDirURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return nil
        }

        return tempDirURL
    }
}
