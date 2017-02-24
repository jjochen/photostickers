//
//  EditStickerViewModel.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 23/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Log

protocol EditStickerViewModelType {
    var stickerInfo: StickerInfo! { get }
    var saveButtonItemDidTap: PublishSubject<Void> { get }
    var cancelButtonItemDidTap: PublishSubject<Void> { get }
    var deleteButtonItemDidTap: PublishSubject<Void> { get }
    var photosButtonItemDidTap: PublishSubject<Void> { get }
    var imagePicked: PublishSubject<UIImage?> { get }
    var presentImagePicker: Observable<UIImagePickerControllerSourceType> { get }
}

class EditStickerViewModel: BaseViewModel, EditStickerViewModelType {

    // MARK: Dependencies
    let stickerInfo: StickerInfo!
    fileprivate let imageStoreService: ImageStoreServiceType!
    fileprivate let stickerService: StickerServiceType!
    fileprivate let stickerRenderService: StickerRenderServiceType!

    // MARK: Input
    let saveButtonItemDidTap = PublishSubject<Void>()
    let cancelButtonItemDidTap = PublishSubject<Void>()
    let deleteButtonItemDidTap = PublishSubject<Void>()
    let photosButtonItemDidTap = PublishSubject<Void>()
    let imagePicked = PublishSubject<UIImage?>()

    // MARK: Output
    let presentImagePicker: Observable<UIImagePickerControllerSourceType>

    init(sticker: Sticker!,
         imageStoreService: ImageStoreServiceType!,
         stickerService: StickerServiceType!,
         stickerRenderService: StickerRenderServiceType!) {

        self.stickerInfo = StickerInfo(sticker: sticker)
        self.imageStoreService = imageStoreService
        self.stickerService = stickerService
        self.stickerRenderService = stickerRenderService

        self.presentImagePicker = self.photosButtonItemDidTap
            .map {
                return .photoLibrary
            }
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentMainScheduler.instance)

        super.init()

        _ = self.imagePicked
            .filterNil()
            .bindTo(stickerInfo.originalImage)

        //        let backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)

        //        _ = self.imagePicked
        //            .observeOn(backgroundScheduler)
        //            .map { [weak self] image in
        //                return self?.createDefaultSticker(withOriginalImage: image)
        //            }
        //            .flatMap { (sticker: Sticker?) -> Driver<Sticker?> in
        //                return stickerRenderService.render(sticker).asDriver(onErrorJustReturn: sticker)
        //            }
        //            .subscribe(onNext: { sticker in
        //                stickerService.add(sticker)
        //            })
    }
}
