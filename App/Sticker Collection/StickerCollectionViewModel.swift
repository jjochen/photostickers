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

class StickerCollectionViewModel: BaseViewModel {

    // MARK: Dependencies
    let provider: ServiceProviderType!

    // MARK: Input

    let addButtonItemDidTap = PublishSubject<Void>()
    let imagePicked = PublishSubject<UIImage?>()

    // MARK: Output
    let stickerCellModels: Observable<[StickerCollectionCellModel]>
    let presentImagePicker: Observable<UIImagePickerControllerSourceType>

    init(provider: ServiceProviderType) {
        self.provider = provider

        self.stickerCellModels = provider.realmService.fetchStickers()
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

        guard let originalImage = originalImage else {
            return
        }

        let uuid = UUID().uuidString
        let originalImageURL = self.provider.imageStoreService.storeImage(originalImage, forKey: uuid, inCategory: "originals")

        let imageSize = originalImage.size
        let sideLength = min(imageSize.width, imageSize.height)

        let sticker = Sticker()
        sticker.uuid = uuid
        sticker.originalImageFilePath = originalImageURL?.path
        sticker.localizedDescription = "Sticker"
        sticker.sortOrder = 1
        sticker.cropBounds = CGRect(x: (imageSize.width - sideLength) / 2, y: (imageSize.height - sideLength) / 2, width: sideLength, height: sideLength)

        let renderedSticker = StickerRenderer.render(sticker)

        let renderedStickerURL = self.provider.imageStoreService.storeImage(renderedSticker, forKey: uuid, inCategory: "stickers")
        sticker.renderedStickerFilePath = renderedStickerURL?.path
        self.provider.realmService.add(sticker: sticker)
    }

    // MARK: - View Models
}
