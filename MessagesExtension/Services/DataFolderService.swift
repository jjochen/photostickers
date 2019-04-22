//
//  FileManagement.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 28/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import Log
import Zip

enum DataFolderType {
    case documents
    case documentsPrefilled(subfolder: String)
    case appGroup
    case temporary
    case appGroupPrefilled(subfolder: String)
}

protocol DataFolderServiceType {
    var url: URL? { get }
    var userDefaults: UserDefaults? { get }
    var imagesURL: URL? { get }
    var realmURL: URL? { get }
}

protocol HasDataFolderService {
    var dataFolderService: DataFolderService { get }
}

struct DataFolderService: DataFolderServiceType {
    fileprivate let appGroupID = "group.com.jochen-pfeiffer.photo-stickers"

    fileprivate let type: DataFolderType
    var url: URL?

    init(type: DataFolderType = .documents) {
        self.type = type
        switch type {
        case .documents:
            url = documentsFolderURL()
        case let .documentsPrefilled(subfolder: subfolder):
            url = documentsFolderURL(subfolder: subfolder)
            prefill()
        case .appGroup:
            url = appGroupFolderURL()
        case let .appGroupPrefilled(subfolder: subfolder):
            url = appGroupFolderURL(subfolder: subfolder)
            prefill()
        case .temporary:
            url = temporaryDirectoryURL(subfolder: NSUUID().uuidString)
        }

        Logger.shared.info("Data Folder: \(url?.path ?? "not set!")")
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
}

private extension DataFolderService {
    func documentsFolderURL(subfolder: String? = nil) -> URL? {
        var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        if let subfolder = subfolder, subfolder.count > 0 {
            url?.appendPathComponent(subfolder)
        }
        guard createDirectory(at: url) else {
            return nil
        }
        return url
    }

    func appGroupFolderURL(subfolder: String? = nil) -> URL? {
        var url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
        if let subfolder = subfolder, subfolder.count > 0 {
            url?.appendPathComponent(subfolder)
        }
        guard createDirectory(at: url) else {
            return nil
        }
        return url
    }

    func temporaryDirectoryURL(subfolder: String? = nil) -> URL? {
        var url = URL(fileURLWithPath: NSTemporaryDirectory())
        if let subfolder = subfolder, subfolder.count > 0 {
            url.appendPathComponent(subfolder)
        }
        guard createDirectory(at: url) else {
            return nil
        }
        return url
    }

    func createDirectory(at url: URL?) -> Bool {
        let errorMessage = "Could not create data folder: "

        guard let url = url else {
            fatalErrorWhileDebugging(errorMessage + "URL is nil.")
            return false
        }

        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: url.path) {
            return true
        }

        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            fatalErrorWhileDebugging(errorMessage + error.localizedDescription)
            return false
        }

        return true
    }
}

private extension DataFolderService {
    func prefill() {
        let errorMessage = "Could not prefill data folder: "
        guard let destination = url else {
            fatalErrorWhileDebugging(errorMessage + "URL is nil.")
            return
        }
        guard let prefillContent = Bundle.main.url(forResource: "prefillContent", withExtension: "zip") else {
            fatalErrorWhileDebugging(errorMessage + "No zip file available.")
            return
        }

        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: destination)
            try fileManager.createDirectory(at: destination, withIntermediateDirectories: true, attributes: nil)
            try Zip.unzipFile(prefillContent, destination: destination, overwrite: true, password: nil, progress: nil)
        } catch {
            fatalErrorWhileDebugging(errorMessage + error.localizedDescription)
            return
        }
    }
}
