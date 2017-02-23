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

protocol StickerCollectionViewModelType {
    var stickerCellModels: Observable<[StickerCollectionCellModel]> { get }
    func editStickerViewModel(for sticker: Sticker) -> EditStickerViewModelType
    func addStickerViewModel() -> EditStickerViewModelType
}

class StickerCollectionViewModel: BaseViewModel, StickerCollectionViewModelType {

    // MARK: Dependencies
    fileprivate let imageStoreService: ImageStoreServiceType
    fileprivate let stickerService: StickerServiceType
    fileprivate let stickerRenderService: StickerRenderServiceType

    // MARK: Input

    // MARK: Output
    let stickerCellModels: Observable<[StickerCollectionCellModel]>

    init(imageStoreService: ImageStoreServiceType,
         stickerService: StickerServiceType,
         stickerRenderService: StickerRenderServiceType) {

        self.imageStoreService = imageStoreService
        self.stickerService = stickerService
        self.stickerRenderService = stickerRenderService

        self.stickerCellModels = stickerService.fetchStickers()
            .map { listOfStickers in
                let listOfViewModels = listOfStickers.map { sticker in
                    return StickerCollectionCellModel(sticker)
                }
                return listOfViewModels
            }
        //            .asDriver(onErrorJustReturn: [])

        super.init()
    }

    fileprivate func createDefaultSticker(withOriginalImage image: UIImage?) -> Sticker? {

        guard let originalImage = image else {
            return nil
        }

        let uuid = UUID().uuidString
        let originalImageURL = imageStoreService.storeImage(originalImage, forKey: uuid, inCategory: "originals")

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

    func editStickerViewModel(for sticker: Sticker) -> EditStickerViewModelType {
        return EditStickerViewModel(sticker: sticker,
                                    imageStoreService: self.imageStoreService,
                                    stickerService: self.stickerService,
                                    stickerRenderService: self.stickerRenderService)
    }

    func addStickerViewModel() -> EditStickerViewModelType {
        return editStickerViewModel(for: Sticker.newSticker())
    }
}
