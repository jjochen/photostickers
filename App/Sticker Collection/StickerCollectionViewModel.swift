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

        stickerCellModels = stickerService.fetchStickers()
            .map { listOfStickers in
                let listOfViewModels = listOfStickers.map { sticker in
                    return StickerCollectionCellModel(sticker)
                }
                return listOfViewModels
            }
        //            .asDriver(onErrorJustReturn: [])

        super.init()
    }

    // MARK: - View Models

    func editStickerViewModel(for sticker: Sticker) -> EditStickerViewModelType {

        return EditStickerViewModel(sticker: sticker,
                                    imageStoreService: imageStoreService,
                                    stickerService: stickerService,
                                    stickerRenderService: stickerRenderService)
    }

    func addStickerViewModel() -> EditStickerViewModelType {
        return editStickerViewModel(for: Sticker.newSticker())
    }
}
