//
//  StickerService.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 09/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import Log
import RealmSwift
import RxRealm
import RxSwift

enum RealmType {
    case inMemory
    case onDisk(url: URL?)
}

protocol StickerServiceType {
    func fetchStickers(withPredicate predicate: NSPredicate) -> Observable<[Sticker]>
    func fetchStickers() -> Observable<[Sticker]>
    func storeSticker(withInfo stickerInfo: StickerInfo) -> Observable<Sticker>
    func deleteSticker(withUUID uuid: String) -> Observable<Void>
}

protocol HasStickerService {
    var stickerService: StickerService { get }
}

class StickerService: StickerServiceType {
    fileprivate let imageStoreService: ImageStoreService
    fileprivate let realmType: RealmType

    fileprivate lazy var mainThreadRealm: Realm = {
        let realm = self.newRealm()
        return realm
    }()

    init(realmType: RealmType, imageStoreService: ImageStoreService) {
        self.realmType = realmType
        self.imageStoreService = imageStoreService

        switch realmType {
        case .inMemory:
            Logger.shared.warning("Realm in memory only")
        case let .onDisk(url: url):
            if url == nil {
                fatalErrorWhileDebugging("Realm: URL not set!")
            }
        }
    }
}

extension StickerService {
    fileprivate func newRealm() -> Realm {
        switch realmType {
        case .inMemory:
            return try! Realm(configuration: Realm.stickerConfigurationInMemory())
        case let .onDisk(url: url):
            return try! Realm(configuration: Realm.stickerConfiguration(with: url))
        }
    }

    fileprivate func currentRealm() -> Realm {
        if Thread.current.isMainThread {
            return mainThreadRealm
        } else {
            return newRealm()
        }
    }
}

extension StickerService {
    func fetchStickers() -> Observable<[Sticker]> {
        return fetchStickers(withPredicate: NSPredicate(value: true))
    }

    func fetchStickers(withPredicate predicate: NSPredicate) -> Observable<[Sticker]> {
        let sortDescriptors = [
            SortDescriptor(keyPath: StickerProperty.sortOrder.rawValue, ascending: true),
        ]
        let results = currentRealm()
            .objects(Sticker.self)
            .filter(predicate)
            .sorted(by: sortDescriptors)
        let stickers = Observable
            .array(from: results)
        return stickers
    }

    func storeSticker(withInfo stickerInfo: StickerInfo) -> Observable<Sticker> {
        return Observable.create { [weak self] observer in
            guard let realm = self?.currentRealm() else {
                observer.on(.error(PSError.unknown))
                // TODO: new error types
                return Disposables.create()
            }

            let sticker: Sticker?
            do {
                sticker = try self?.sticker(withInfo: stickerInfo, inRealm: realm)
            } catch {
                observer.on(.error(error))
                return Disposables.create()
            }

            guard let nextSticker = sticker else {
                observer.on(.error(PSError.unknown))
                // TODO: new error types
                return Disposables.create()
            }

            observer.on(.next(nextSticker))
            observer.on(.completed)
            return Disposables.create()
        }
    }

    func deleteSticker(withUUID uuid: String) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.on(.error(PSError.unknown))
                // TODO: new error types
                return Disposables.create()
            }

            let realm = self.currentRealm()

            guard let sticker = realm.object(ofType: Sticker.self, forPrimaryKey: uuid) else {
                observer.on(.error(PSError.unknown))
                // TODO: new error types
                return Disposables.create()
            }

            sticker.deleteOriginalImage()
            sticker.deleteRenderedImage()

            do {
                try realm.write {
                    realm.delete(sticker)
                }
            } catch {
                observer.on(.error(error))
                return Disposables.create()
            }

            observer.on(.next(()))
            observer.on(.completed)
            return Disposables.create()
        }
    }

    func deleteAll() {
        let realm = currentRealm()
        try! realm.write {
            realm.deleteAll()
        }
    }
}

private extension StickerService {
    func sticker(withInfo info: StickerInfo, inRealm realm: Realm) throws -> Sticker {
        let sticker = try realm.sticker(withUUID: info.uuid)
        try update(sticker: sticker, withInfo: info)
        return sticker
    }

    func update(sticker: Sticker, withInfo info: StickerInfo) throws {
        guard let realm = sticker.realm else {
            fatalErrorWhileDebugging("update sticker only works with stickers in realm")
            throw PSError.unknown
            // TODO: new error types
        }

        try realm.write {
            if info.titleDidChange {
                sticker.title = info.title.value
            }
            if info.originalImageDidChange {
                sticker.store(originalImage: info.originalImage.value, in: imageStoreService)
            }
            if info.renderedStickerDidChange {
                sticker.store(renderedImage: info.renderedSticker.value, in: imageStoreService)
            }
            if info.cropBoundsDidChange {
                sticker.cropBounds = info.cropBounds.value
            }
            if info.maskDidChange {
                sticker.mask = info.mask.value
            }
            if info.sortOrderDidChange {
                sticker.sortOrder = info.sortOrder.value
            }
        }
    }
}

private extension Sticker {
    func store(originalImage image: UIImage?, in imageStoreService: ImageStoreService) {
        guard let image = image else {
            // handle error
            return
        }
        guard let url = imageStoreService.store(originalImage: image, forKey: uuid) else {
            // handle error
            return
        }
        originalImageFilePath = url.path
    }

    func store(renderedImage image: UIImage?, in imageStoreService: ImageStoreService) {
        guard let image = image else {
            // handle error
            return
        }
        let previousFilePath = renderedImageFilePath
        let newVersion = renderedImageVersion + 1
        guard let url = imageStoreService.store(renderedImage: image, forKey: uuid, version: newVersion) else {
            // handle error
            return
        }
        renderedImageVersion = newVersion
        renderedImageFilePath = url.path

        if let path = previousFilePath {
            try? FileManager.default.removeItem(atPath: path)
        }
    }
}

private extension Realm {
    func sticker(withUUID uuid: String?) throws -> Sticker {
        return try fetchSticker(withUUID: uuid) ?? newSticker()
    }

    func fetchSticker(withUUID uuid: String?) -> Sticker? {
        return object(ofType: Sticker.self, forPrimaryKey: uuid)
    }

    func newSticker() throws -> Sticker {
        let sticker = Sticker()
        sticker.uuid = NSUUID().uuidString
        sticker.sortOrder = nextSortOrder()
        try write {
            add(sticker, update: false)
        }
        return sticker
    }

    func nextSortOrder() -> Int {
        let maxSortOrder = objects(Sticker.self).max(ofProperty: StickerProperty.sortOrder.rawValue) ?? 0
        return maxSortOrder + 1
    }

    func numberOfStickers(with predicate: NSPredicate) -> Int {
        return objects(Sticker.self).filter(predicate).count
    }
}

private extension Realm {
    static func stickerConfiguration(with fileURL: URL?) -> Configuration {
        return Configuration(
            fileURL: fileURL,
            schemaVersion: 4,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    Realm.performMigrationToVersion1(migration)
                }

                if oldSchemaVersion < 2 {
                    Realm.performMigrationToVersion2(migration)
                }

                if oldSchemaVersion < 3 {
                    Realm.performMigrationToVersion3(migration)
                }

                if oldSchemaVersion < 4 {
                    Realm.performMigrationToVersion4(migration, fileURL: fileURL)
                }
            }
        )
    }

    static func stickerConfigurationInMemory() -> Configuration {
        return Configuration(fileURL: nil,
                             inMemoryIdentifier: "Tests",
                             syncConfiguration: nil,
                             encryptionKey: nil,
                             readOnly: false,
                             schemaVersion: 0,
                             migrationBlock: nil,
                             deleteRealmIfMigrationNeeded: true,
                             objectTypes: nil)
    }

    static func performMigrationToVersion1(_: Migration) {
        // nothing to do, use default value for maskType
    }

    static func performMigrationToVersion2(_ migration: Migration) {
        migration.enumerateObjects(ofType: Sticker.className()) { oldObject, newObject in
            let localizedDescription: String = oldObject!["localizedDescription"] as! String
            let title: String? = localizedDescription.isEmpty ? nil : localizedDescription
            newObject!["title"] = title
        }
    }

    static func performMigrationToVersion3(_ migration: Migration) {
        migration.enumerateObjects(ofType: Sticker.className()) { oldObject, newObject in
            let originalImageFilePath: String? = oldObject!["originalImageFilePath"] as! String?
            let renderedImageFilePath: String? = oldObject!["renderedStickerFilePath"] as! String?
            let hasOriginalImage: Bool = !(originalImageFilePath?.isEmpty ?? true)
            let hasRenderedImage: Bool = !(renderedImageFilePath?.isEmpty ?? true)
            newObject!["hasOriginalImage"] = hasOriginalImage
            newObject!["hasRenderedImage"] = hasRenderedImage
        }
    }

    static func performMigrationToVersion4(_ migration: Migration, fileURL: URL?) {
        guard let baseURL = fileURL?.deletingLastPathComponent().appendingPathComponent("images") else {
            #if DEBUG
                fatalError()
            #else
                return
            #endif
        }
        let imageStore = ImageStoreService(url: baseURL)

        migration.enumerateObjects(ofType: Sticker.className()) { oldObject, newObject in
            newObject!["originalImageFilePath"] = originalImageFilePath(fromOldObject: oldObject, imageStore: imageStore)
            newObject!["renderedImageFilePath"] = renderedImageFilePath(fromOldObject: oldObject, imageStore: imageStore)
        }
    }

    static func originalImageFilePath(fromOldObject oldObject: MigrationObject?, imageStore: ImageStoreService) -> String? {
        let hasOriginalImage: Bool = oldObject!["hasOriginalImage"] as? Bool ?? false
        guard hasOriginalImage else {
            return nil
        }

        guard let uuid: String = oldObject!["uuid"] as? String else {
            #if DEBUG
                fatalError()
            #else
                return nil
            #endif
        }

        let url = imageStore.originalImageURL(forKey: uuid)
        return url?.path
    }

    static func renderedImageFilePath(fromOldObject oldObject: MigrationObject?, imageStore: ImageStoreService) -> String? {
        let hasRenderedImage: Bool = oldObject!["hasRenderedImage"] as? Bool ?? false
        guard hasRenderedImage else {
            return nil
        }

        guard let uuid: String = oldObject!["uuid"] as? String else {
            #if DEBUG
                fatalError()
            #else
                return nil
            #endif
        }

        let url = imageStore.renderedImageURL(forKey: uuid, version: nil) // didn't have versioning yet
        return url?.path
    }
}
