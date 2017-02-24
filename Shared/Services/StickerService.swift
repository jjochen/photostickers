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
    func add(_ sticker: Sticker?)
}

class StickerService: StickerServiceType {

    fileprivate let mainThreadRealm: Realm!

    init(realmURL: URL?) {
        var config = Realm.Configuration()
        config.fileURL = realmURL
        Realm.Configuration.defaultConfiguration = config

        if let path = realmURL?.path {
            Logger.shared.info("Realm: \(path)")
        } else {
            Logger.shared.warning("Realm: URL not set!")
        }

        self.mainThreadRealm = try! Realm()
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
        let results = self.currentRealm()
            .objects(Sticker.self)
            .filter(predicate)
            .sorted(by: sortDescriptors)
        let stickers = Observable
            .array(from: results)
        return stickers
    }

    func add(_ sticker: Sticker?) {
        guard let sticker = sticker else {
            return
        }
        let realm = self.currentRealm()

        if sticker.sortOrder == 0 {
            let maxSortOrder: Int = realm.objects(Sticker.self).max(ofProperty: StickerProperty.sortOrder.rawValue) ?? 0
            sticker.sortOrder = maxSortOrder + 1
        }

        try! realm.write {
            realm.add(sticker, update: true)
        }
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
