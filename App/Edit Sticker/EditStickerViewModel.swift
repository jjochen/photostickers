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
    var stickerInfo: StickerInfo { get }
    var saveButtonItemDidTap: PublishSubject<Void> { get }
    var cancelButtonItemDidTap: PublishSubject<Void> { get }
    var deleteButtonItemDidTap: PublishSubject<Void> { get }
    var photosButtonItemDidTap: PublishSubject<Void> { get }
    var imagePicked: PublishSubject<UIImage?> { get }

    var saveButtonItemEnabled: Driver<Bool> { get }
    var presentImagePicker: Observable<UIImagePickerControllerSourceType> { get }
    var dismissViewController: Observable<Void> { get }
}

class EditStickerViewModel: BaseViewModel, EditStickerViewModelType {

    let disposeBag = DisposeBag()

    // MARK: Dependencies
    let stickerInfo: StickerInfo
    fileprivate let imageStoreService: ImageStoreServiceType
    fileprivate let stickerService: StickerServiceType
    fileprivate let stickerRenderService: StickerRenderServiceType

    // MARK: Input
    let saveButtonItemDidTap = PublishSubject<Void>()
    let cancelButtonItemDidTap = PublishSubject<Void>()
    let deleteButtonItemDidTap = PublishSubject<Void>()
    let photosButtonItemDidTap = PublishSubject<Void>()
    let imagePicked = PublishSubject<UIImage?>()

    // MARK: Output
    let saveButtonItemEnabled: Driver<Bool>
    let presentImagePicker: Observable<UIImagePickerControllerSourceType>
    let dismissViewController: Observable<Void>

    init(sticker: Sticker,
         imageStoreService: ImageStoreServiceType,
         stickerService: StickerServiceType,
         stickerRenderService: StickerRenderServiceType) {

        let stickerInfo = StickerInfo(sticker: sticker)
        self.stickerInfo = stickerInfo
        self.imageStoreService = imageStoreService
        self.stickerService = stickerService
        self.stickerRenderService = stickerRenderService

        self.saveButtonItemEnabled = Observable.combineLatest(stickerInfo.originalImageIsNil, stickerInfo.cropBoundsAreEmpty) { (originalImageIsNil, cropBoundsAreEmpty) -> Bool in
            return !originalImageIsNil && !cropBoundsAreEmpty
        }
        .startWith(false)
        .distinctUntilChanged()
        .asDriver(onErrorJustReturn: false)

        let originalImageIsNil = self.stickerInfo
            .originalImageIsNil
            .filter { $0 }
            .map { _ in Void() }

        self.presentImagePicker = Observable
            .of(self.photosButtonItemDidTap, originalImageIsNil)
            .merge()
            .map {
                return .photoLibrary
            }
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentMainScheduler.instance)

        let stickerWasRendered = self.stickerInfo
            .renderedSticker
            .asObservable()
            .skip(1)
            .map { _ in Void() }

        let stickerWasSaved = stickerWasRendered
            .asObservable()
            .flatMap {
                return stickerService.storeSticker(withInfo: stickerInfo)
            }
            .map { _ in Void() }

        self.dismissViewController = Observable
            .of(self.cancelButtonItemDidTap, stickerWasSaved)
            .merge()
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentMainScheduler.instance)

        super.init()

        self.imagePicked
            .filterNil()
            .bindTo(stickerInfo.originalImage)
            .disposed(by: self.disposeBag)

        let backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)
        self.saveButtonItemDidTap
            .withLatestFrom(self.saveButtonItemEnabled)
            .filter { isEnabled in isEnabled }
            .observeOn(backgroundScheduler)
            .flatMap { _ in
                return stickerRenderService.render(stickerInfo).asDriver(onErrorJustReturn: nil)
            }
            .filterNil()
            .bindTo(self.stickerInfo.renderedSticker)
            .disposed(by: self.disposeBag)

        self.stickerInfo
            .originalImage
            .asObservable()
            .filterNil()
            .map { image in
                let imageSize = image.size
                let sideLength = min(imageSize.width, imageSize.height)
                return CGRect(x: (imageSize.width - sideLength) / 2, y: (imageSize.height - sideLength) / 2, width: sideLength, height: sideLength)
            }
            .bindTo(self.stickerInfo.cropBounds)
            .disposed(by: self.disposeBag)
    }
}
