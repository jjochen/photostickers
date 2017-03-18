//
//  StickerService.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 09/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxRealm
import Log

protocol StickerServiceType {
    func fetchStickers(withPredicate predicate: NSPredicate) -> Observable<[Sticker]>
    func fetchStickers() -> Observable<[Sticker]>
    func storeSticker(withInfo stickerInfo: StickerInfo) -> Observable<Sticker>
    func deleteSticker(withUUID uuid: String) -> Observable<Void>
}

class StickerService: StickerServiceType {

    fileprivate let mainThreadRealm: Realm
    fileprivate let imageStoreService: ImageStoreServiceType

    init(realmURL: URL?, imageStoreService: ImageStoreServiceType) {

        Realm.Configuration.defaultConfiguration = Realm.stickerConfiguration(with: realmURL)

        if let path = realmURL?.path {
            Logger.shared.info("Realm: \(path)")
        } else {
            Logger.shared.warning("Realm: URL not set!")
        }

        self.mainThreadRealm = try! Realm()

        self.imageStoreService = imageStoreService
    }
}

extension StickerService {
    fileprivate func currentRealm() -> Realm {
        if Thread.current.isMainThread {
            return self.mainThreadRealm
        } else {
            return try! Realm()
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
                observer.on(.error(PSError.unknown)) // todo
                return Disposables.create()
            }

            let sticker: Sticker?
            do {
                sticker = try self?.sticker(withInfo: stickerInfo, inRealm: realm)
            } catch let error {
                observer.on(.error(error))
                return Disposables.create()
            }

            guard let nextSticker = sticker else {
                observer.on(.error(PSError.unknown)) // todo
                return Disposables.create()
            }

            observer.on(.next(nextSticker))
            observer.on(.completed)
            return Disposables.create()
        }
    }

    func deleteSticker(withUUID uuid: String) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let realm = self?.currentRealm() else {
                observer.on(.error(PSError.unknown)) // todo
                return Disposables.create()
            }

            guard let sticker = realm.object(ofType: Sticker.self, forPrimaryKey: uuid) else {
                observer.on(.error(PSError.unknown)) // todo
                return Disposables.create()
            }

            do {
                if let originalImageFilePath = sticker.originalImageFilePath {
                    try FileManager.default.removeItem(atPath: originalImageFilePath)
                }
                if let renderedStickerFilePath = sticker.renderedStickerFilePath {
                    try FileManager.default.removeItem(atPath: renderedStickerFilePath)
                }
            } catch let error {
                Logger.shared.error(error)
            }

            do {
                try realm.write {
                    realm.delete(sticker)
                }
            } catch let error {
                observer.on(.error(error))
                return Disposables.create()
            }

            observer.on(.next())
            observer.on(.completed)
            return Disposables.create()
        }
    }
}

extension StickerService {

    fileprivate func sticker(withInfo info: StickerInfo, inRealm realm: Realm) throws -> Sticker {
        let sticker = try realm.sticker(withUUID: info.uuid)
        try self.update(sticker: sticker, withInfo: info)
        return sticker
    }

    fileprivate func update(sticker: Sticker, withInfo info: StickerInfo) throws {
        guard let realm = sticker.realm else {
            Logger.shared.error("update sticker only works with stickers in realm")
            throw PSError.unknown // todo
        }

        try realm.write {
            if info.localizedDescriptionDidChange {
                sticker.localizedDescription = info.localizedDescription.value
            }
            if info.originalImageDidChange {
                if let url = storeImage(info.originalImage.value, forKey: sticker.uuid, inCategory: "originals") {
                    sticker.originalImageFilePath = url.path
                }
            }
            if info.renderedStickerDidChange {
                if let url = storeImage(info.renderedSticker.value, forKey: sticker.uuid, inCategory: "stickers") {
                    sticker.renderedStickerFilePath = url.path
                }
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

    fileprivate func storeImage(_ image: UIImage?, forKey key: String?, inCategory category: String) -> URL? {
        guard let image = image else {
            return nil
        }

        guard let key = key else {
            return nil
        }

        guard !key.isEmpty else {
            return nil
        }

        return self.imageStoreService.storeImage(image, forKey: key, inCategory: category)
    }
}

extension Realm {
    fileprivate func sticker(withUUID uuid: String?) throws -> Sticker {
        return try fetchSticker(withUUID: uuid) ?? newSticker()
    }

    fileprivate func fetchSticker(withUUID uuid: String?) -> Sticker? {
        return object(ofType: Sticker.self, forPrimaryKey: uuid)
    }

    fileprivate func newSticker() throws -> Sticker {
        let sticker = Sticker()
        sticker.uuid = NSUUID().uuidString
        sticker.sortOrder = nextSortOrder()
        try write {
            add(sticker, update: false)
        }
        return sticker
    }

    fileprivate func nextSortOrder() -> Int {
        let maxSortOrder = objects(Sticker.self).max(ofProperty: StickerProperty.sortOrder.rawValue) ?? 0
        return maxSortOrder + 1
    }
}

extension Realm {
    fileprivate static func stickerConfiguration(with fileURL: URL?) -> Configuration {
        return Configuration(
            fileURL: fileURL,
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // nothing to do (use default value for maskType)
                }
        })
    }
}
