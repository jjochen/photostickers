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


final class StickerBrowserViewModel: ServicesViewModel {
    typealias Services = AppServices
    var services: AppServices!

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
        let sectionItems = services.stickerService
            .fetchStickers(withPredicate: predicate)
            .map { allStickers -> [StickerSectionItem] in
                var items = allStickers.map { sticker -> StickerSectionItem in
                    let cellViewModel: StickerBrowserCellViewModelType = StickerBrowserCellViewModel(sticker: sticker,
                                                                                                     editing: isEditing,
                                                                                                     imageStore: self.services.imageStoreService)
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
