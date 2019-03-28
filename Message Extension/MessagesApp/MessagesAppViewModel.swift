//
//  MessagesAppViewModel.swift
//  MessageExtension
//
//  Created by Jochen on 28.03.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import Log
import Messages
import RealmSwift
import RxCocoa
import RxRealm
import RxSwift

protocol MessagesAppViewModelType {
    var currentPresentationStyle: PublishSubject<MSMessagesAppPresentationStyle> { get }
    // var requestPresentationStyle: Driver<MSMessagesAppPresentationStyle> { get }
    func stickerBrowserViewModel() -> PhotoStickerBrowserViewModelType
}

class MessagesAppViewModel: BaseViewModel, MessagesAppViewModelType {
    // MARK: Dependencies

    fileprivate let extensionContext: NSExtensionContext?
    fileprivate let stickerService: StickerServiceType
    fileprivate let imageStoreService: ImageStoreServiceType
    fileprivate let stickerRenderService: StickerRenderServiceType

    // MARK: Input

    let currentPresentationStyle = PublishSubject<MSMessagesAppPresentationStyle>()

    // MARK: Output

    // let requestPresentationStyle: Driver<MSMessagesAppPresentationStyle>

    init(stickerService: StickerServiceType,
         imageStoreService: ImageStoreServiceType,
         stickerRenderService: StickerRenderServiceType,
         extensionContext: NSExtensionContext?) {
        self.stickerService = stickerService
        self.imageStoreService = imageStoreService
        self.stickerRenderService = stickerRenderService
        self.extensionContext = extensionContext

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

    func stickerBrowserViewModel() -> PhotoStickerBrowserViewModelType {
        return PhotoStickerBrowserViewModel(stickerService: stickerService,
                                            imageStoreService: imageStoreService,
                                            stickerRenderService: stickerRenderService,
                                            extensionContext: extensionContext)
    }
}
