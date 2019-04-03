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
import RxFlow
import RxRealm
import RxSwift

final class StickerBrowserViewModel: ServicesViewModel, Stepper {
    typealias Services = AppServices
    var services: AppServices!

    let steps = PublishRelay<Step>()

    struct Input {
        let actionButtonDidTap: Driver<StickerBrowserActionButtonType>
        let currentPresentationStyle: Driver<MSMessagesAppPresentationStyle>
    }

    struct Output {
        let sectionItems: Observable<[StickerSectionItem]>
        let navigationBarHidden: Driver<Bool>
        let actionButtonType: Driver<StickerBrowserActionButtonType>
        let requestPresentationStyle: Driver<MSMessagesAppPresentationStyle>
    }

    func transform(input: StickerBrowserViewModel.Input) -> StickerBrowserViewModel.Output {
        let isEditing = input.actionButtonDidTap
            .map { $0 == .edit }
            .startWith(false)
            .asDriver(onErrorJustReturn: false)

        let navigationBarHidden = input.currentPresentationStyle
            .map { $0 != .expanded }
            .startWith(true)
            .asDriver(onErrorJustReturn: true)

        let actionButtonType = isEditing
            .map { $0 ? StickerBrowserActionButtonType.done : StickerBrowserActionButtonType.edit }
            .debug()

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

        let shouldExpand = isEditing
            .filter { $0 }
            .map { _ in Void() }

        let requestPresentationStyle = shouldExpand
            .map { MSMessagesAppPresentationStyle.expanded }

        return Output(sectionItems: sectionItems,
                      navigationBarHidden: navigationBarHidden,
                      actionButtonType: actionButtonType,
                      requestPresentationStyle: requestPresentationStyle)
    }
}
