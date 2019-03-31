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

final class MessagesAppViewModel: ViewModelType {
    struct Input {
       // let currentPresentationStyle: Driver<MSMessagesAppPresentationStyle>
    }
    struct Output {
       let presentationStyleRequested: Driver<MSMessagesAppPresentationStyle>
    }

    private let extensionContext: NSExtensionContext?
    private let stickerService: StickerServiceType
    private let imageStoreService: ImageStoreServiceType
    private let stickerRenderService: StickerRenderServiceType

    private let presentationStyleSubject = PublishSubject<MSMessagesAppPresentationStyle>()

    init(stickerService: StickerServiceType,
         imageStoreService: ImageStoreServiceType,
         stickerRenderService: StickerRenderServiceType,
         extensionContext: NSExtensionContext?) {
        self.stickerService = stickerService
        self.imageStoreService = imageStoreService
        self.stickerRenderService = stickerRenderService
        self.extensionContext = extensionContext
    }

    func transform(input: Input) -> Output {
        let presentationStyleRequested = presentationStyleSubject.asDriver(onErrorDriveWith: Driver.empty())
        return Output(presentationStyleRequested: presentationStyleRequested)
    }
}

// MARK: - View Models
extension MessagesAppViewModel {
    func stickerBrowserViewModel() -> StickerBrowserViewModel {
        return StickerBrowserViewModel(stickerService: stickerService,
                                       imageStoreService: imageStoreService,
                                       stickerRenderService: stickerRenderService,
                                       extensionContext: extensionContext)
    }
}
