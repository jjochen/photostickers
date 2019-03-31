//
//  PhotoStickerBrowserViewModel.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 30/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import Log
import Messages
import RealmSwift
import RxCocoa
import RxRealm
import RxSwift


final class StickerBrowserViewModel: ViewModelType {

    struct Input {
        let editButtonDidTap: Driver<Void>
        let doneButtonDidTap: Driver<Void>
        let currentPresentationStyle: Driver<MSMessagesAppPresentationStyle>
    }
    struct Output {
        let sectionItems: Observable<[StickerSectionItem]>
        let navigationBarHidden: Driver<Bool>
        let editButtonHidden: Driver<Bool>
        let doneButtonHidden: Driver<Bool>
        let requestPresentationStyle: Driver<MSMessagesAppPresentationStyle>
    }

    private let extensionContext: NSExtensionContext?
    private let stickerService: StickerServiceType
    private let imageStoreService: ImageStoreServiceType
    private let stickerRenderService: StickerRenderServiceType

    init(stickerService: StickerServiceType,
         imageStoreService: ImageStoreServiceType,
         stickerRenderService: StickerRenderServiceType,
         extensionContext: NSExtensionContext?) {
        self.stickerService = stickerService
        self.imageStoreService = imageStoreService
        self.stickerRenderService = stickerRenderService
        self.extensionContext = extensionContext
    }


    func transform(input: StickerBrowserViewModel.Input) -> StickerBrowserViewModel.Output {

        let isEditing = input.editButtonDidTap
            .scan(false) { previous, _ in !previous }
            .startWith(false)
            .asDriver(onErrorJustReturn: false)

        let navigationBarHidden = input.currentPresentationStyle
            .map { $0 != .expanded }
            .startWith(true)
            .asDriver(onErrorJustReturn: true)

        let editButtonHidden = isEditing

        let doneButtonHidden = isEditing.map { !$0 }

        let predicate = NSPredicate(format: "\(StickerProperty.hasRenderedImage.rawValue) == true")
        let sectionItems = stickerService
            .fetchStickers(withPredicate: predicate)
            .map { allStickers -> [StickerSectionItem] in
                var items = allStickers.map { sticker -> StickerSectionItem in
                    let cellViewModel: StickerBrowserCellViewModelType = StickerBrowserCellViewModel(sticker: sticker,
                                                                                                     editing: isEditing,
                                                                                                     imageStore: self.imageStoreService)
                    return StickerSectionItem.stickerItem(viewModel: cellViewModel)
                }
                items.append(StickerSectionItem.openAppItem)
                return items
        }

        let requestPresentationStyle = input.editButtonDidTap
            .map { MSMessagesAppPresentationStyle.expanded }

        return Output(sectionItems: sectionItems,
                      navigationBarHidden: navigationBarHidden,
                      editButtonHidden: editButtonHidden,
                      doneButtonHidden: doneButtonHidden,
                      requestPresentationStyle: requestPresentationStyle)

    }
}

// MARK: - View Models
extension StickerBrowserViewModel {
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
