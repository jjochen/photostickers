//
//  PhotoStickerBrowserViewModel.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 30/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import RealmSwift
import RxRealm
import RxSwift

protocol PhotoStickerBrowserViewModelType {
    var stickerService: StickerServiceType { get }
    var sectionItems: Observable<[StickerSectionItem]> { get }
    func openApp()
    func editStickerViewModel(for sticker: Sticker) -> EditStickerViewModelType
    func addStickerViewModel() -> EditStickerViewModelType
}

class PhotoStickerBrowserViewModel: BaseViewModel, PhotoStickerBrowserViewModelType {
    // MARK: Dependencies

    let extensionContext: NSExtensionContext?
    let stickerService: StickerServiceType
    let imageStoreService: ImageStoreServiceType
    fileprivate let stickerRenderService: StickerRenderServiceType

    // MARK: Output

    var sectionItems: Observable<[StickerSectionItem]>

    init(stickerService: StickerServiceType,
         imageStoreService: ImageStoreServiceType,
         stickerRenderService: StickerRenderServiceType,
         extensionContext: NSExtensionContext?) {
        self.stickerService = stickerService
        self.imageStoreService = imageStoreService
        self.stickerRenderService = stickerRenderService
        self.extensionContext = extensionContext

        let predicate = NSPredicate(format: "\(StickerProperty.hasRenderedImage.rawValue) == true")
        sectionItems = stickerService
            .fetchStickers(withPredicate: predicate)
            .map { allStickers in
                var items = allStickers.map { sticker -> StickerSectionItem in
                    let cellViewModel: StickerBrowserCellViewModelType = StickerBrowserCellViewModel(sticker: sticker, imageStore: imageStoreService)
                    return StickerSectionItem.stickerItem(viewModel: cellViewModel)
                }
                items.append(StickerSectionItem.openAppItem)
                return items
            }

        super.init()
    }

    func openApp() {
        if let url = URL(string: "photosticker://create") {
            extensionContext?.open(url, completionHandler: nil)
        }
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
