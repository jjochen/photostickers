//
//  StickerServiceMock.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 17.04.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import RxSwift
@testable import PhotoStickers

class StickerServiceMock: StickerServiceType {

    fileprivate let stickers = Variable<[Sticker]>([])

    func set(mockedStickers: [Sticker]) {
        stickers.value = mockedStickers
    }

    func fetchStickers(withPredicate _: NSPredicate) -> Observable<[Sticker]> {
        return stickers.asObservable()
    }

    func fetchStickers() -> Observable<[Sticker]> {
        return stickers.asObservable()
    }

    func storeSticker(withInfo _: StickerInfo) -> Observable<Sticker> {
        return Observable.empty() // todo
    }

    func deleteSticker(withUUID _: String) -> Observable<Void> {
        return Observable.empty() // todo
    }
}
