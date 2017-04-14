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

protocol StickerCollectionViewModelType: class {
    var stickerCellModels: Driver<[StickerCollectionCellModel]> { get }
    var presentFirstStickerAlert: Driver<Void> { get }
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
    let stickerCellModels: Driver<[StickerCollectionCellModel]>
    let presentFirstStickerAlert: Driver<Void>

    init(imageStoreService: ImageStoreServiceType,
         stickerService: StickerServiceType,
         stickerRenderService: StickerRenderServiceType) {

        self.imageStoreService = imageStoreService
        self.stickerService = stickerService
        self.stickerRenderService = stickerRenderService

        let stickers = stickerService
            .fetchStickers()
            .shareReplay(1)

        presentFirstStickerAlert = stickers // might change to: sticker was added and message was not shown yet
            .map { allStickers in
                return allStickers.count
            }
            .distinctUntilChanged()
            .scan([]) { lastSlice, newValue -> [Int] in
                return Array(Array(lastSlice + [newValue]).suffix(2))
            }
            .filter { $0 == [0, 1] }
            .map { _ in Void() }
            .asDriver(onErrorDriveWith: Driver.empty())

        stickerCellModels = stickers
            .map { listOfStickers in
                let listOfViewModels = listOfStickers.map { sticker in
                    return StickerCollectionCellModel(sticker: sticker, imageStoreService: imageStoreService)
                }
                return listOfViewModels
            }
            .asDriver(onErrorJustReturn: [])

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
