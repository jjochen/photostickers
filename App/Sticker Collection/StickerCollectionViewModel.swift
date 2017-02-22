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

        let backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)

        _ = self.imagePicked
            .observeOn(backgroundScheduler)
            .map { [weak self] image in
                return self?.createDefaultSticker(withOriginalImage: image)
            }
            .flatMap { (sticker: Sticker?) -> Driver<Sticker?> in
                return provider.stickerRenderService.render(sticker).asDriver(onErrorJustReturn: sticker)
            }
            .subscribe(onNext: { sticker in
                provider.realmService.addOrUpdate(sticker)
            })
    }

    fileprivate func createDefaultSticker(withOriginalImage image: UIImage?) -> Sticker? {

        guard let originalImage = image else {
            return nil
        }

        let uuid = UUID().uuidString
        let originalImageURL = self.provider.imageStoreService.storeImage(originalImage, forKey: uuid, inCategory: "originals")

        let imageSize = originalImage.size
        let sideLength = min(imageSize.width, imageSize.height)
        let cropBounds = CGRect(x: (imageSize.width - sideLength) / 2, y: (imageSize.height - sideLength) / 2, width: sideLength, height: sideLength)

        let sticker = Sticker()
        sticker.uuid = uuid
        sticker.originalImageFilePath = originalImageURL?.path
        sticker.localizedDescription = "Sticker"
        sticker.cropBounds = cropBounds

        return sticker
    }

    // MARK: - View Models
}
