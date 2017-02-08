//
//  StickerCollectionViewModel.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 06/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

class StickerCollectionViewModel: ViewModel {

    // MARK: Dependencies
    let realmContext: Realm!

    // MARK: Input

    let addButtonItemDidTap = PublishSubject<Void>()
    let imagePicked = PublishSubject<UIImage?>()

    // MARK: Output
    let stickerCellModels: Observable<[StickerCollectionCellModel]>
    let presentImagePicker: Observable<UIImagePickerControllerSourceType>

    init(realmContext: Realm!) {
        self.realmContext = realmContext

        let stickers = self.realmContext.objects(Sticker.self)
        self.stickerCellModels = Observable
            .array(from: stickers)
            .map { listOfStickers in
                let listOfViewModels = listOfStickers.map { sticker in
                    return StickerCollectionCellModel(sticker)
                }
                return listOfViewModels
            }
        //            .asDriver(onErrorJustReturn: [])

        self.presentImagePicker = self.addButtonItemDidTap
            .map {
                return .photoLibrary
            }
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentMainScheduler.instance)

        super.init()

        _ = self.imagePicked
            .subscribe(onNext: { image in
                self.storeSticker(withOriginalImage: image)
            })
    }

    fileprivate func storeSticker(withOriginalImage originalImage: UIImage?) {

        guard let _ = originalImage else {
            return
        }

        let sticker = Sticker()
        sticker.uuid = UUID().uuidString
        sticker.originalImage = originalImage
        sticker.localizedDescription = "Sticker"
        sticker.sortOrder = 1
        sticker.cropBounds = CGRect(x: 0, y: 0, width: 600, height: 600)

        StickerRenderer.render(sticker)

        try! realmContext.write {
            realmContext.add(sticker)
        }
    }

    // MARK: - View Models
}
