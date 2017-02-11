//
//  realmService.swift
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

protocol RealmServiceType {
    func fetchStickers(withPredicate predicate: NSPredicate) -> Observable<[Sticker]>
    func fetchStickers() -> Observable<[Sticker]>
    func add(sticker: Sticker)
}

class RealmService: BaseService, RealmServiceType {

    fileprivate let mainThreadRealm: Realm!

    init(provider: ServiceProviderType, url: URL?) {

        var config = Realm.Configuration()
        config.fileURL = url
        Realm.Configuration.defaultConfiguration = config

        self.mainThreadRealm = try! Realm()

        super.init(provider: provider)
    }
}

extension RealmService {
    func fetchStickers() -> Observable<[Sticker]> {
        return fetchStickers(withPredicate: NSPredicate(value: true))
    }

    func fetchStickers(withPredicate predicate: NSPredicate) -> Observable<[Sticker]> {
        let sortDescriptors = [
            SortDescriptor(keyPath: "sortOrder", ascending: true),
        ]
        let results = self.currentRealm()
            .objects(Sticker.self)
            .filter(predicate)
            .sorted(by: sortDescriptors)
        let stickers = Observable
            .array(from: results)
        return stickers
    }

    func add(sticker: Sticker) {
        let realm = self.currentRealm()
        try! realm.write {
            realm.add(sticker)
        }
    }
}

extension RealmService {
    fileprivate func currentRealm() -> Realm {
        if Thread.current.isMainThread {
            return self.mainThreadRealm
        } else {
            return try! Realm()
        }
    }
}
