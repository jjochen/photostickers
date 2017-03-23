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
    var saveButtonItemDidTap: PublishSubject<Void> { get }
    var cancelButtonItemDidTap: PublishSubject<Void> { get }
    var deleteButtonItemDidTap: PublishSubject<Void> { get }
    var photosButtonItemDidTap: PublishSubject<Void> { get }
    var didPickImage: PublishSubject<UIImage?> { get }
    var visibleRectDidChange: PublishSubject<CGRect> { get }
    var stickerTitleDidChange: PublishSubject<String?> { get }

    var imageWithVisibleRect: Driver<(UIImage?, CGRect)> { get }
    var mask: Driver<Mask> { get }
    var saveButtonItemEnabled: Driver<Bool> { get }
    var deleteButtonItemEnabled: Driver<Bool> { get }
    var stickerPlaceholderHidden: Driver<Bool> { get }
    var presentImagePicker: Observable<UIImagePickerControllerSourceType> { get }
    var dismissViewController: Observable<Void> { get }
}

class EditStickerViewModel: BaseViewModel, EditStickerViewModelType {

    let disposeBag = DisposeBag()

    // MARK: Dependencies
    fileprivate let stickerInfo: StickerInfo
    fileprivate let imageStoreService: ImageStoreServiceType
    fileprivate let stickerService: StickerServiceType
    fileprivate let stickerRenderService: StickerRenderServiceType

    // MARK: Input
    let saveButtonItemDidTap = PublishSubject<Void>()
    let cancelButtonItemDidTap = PublishSubject<Void>()
    let deleteButtonItemDidTap = PublishSubject<Void>()
    let photosButtonItemDidTap = PublishSubject<Void>()
    let didPickImage = PublishSubject<UIImage?>()
    let visibleRectDidChange = PublishSubject<CGRect>()
    let stickerTitleDidChange = PublishSubject<String?>()

    // MARK: Output
    let imageWithVisibleRect: Driver<(UIImage?, CGRect)>
    let mask: Driver<Mask>
    let saveButtonItemEnabled: Driver<Bool>
    let deleteButtonItemEnabled: Driver<Bool>
    let stickerPlaceholderHidden: Driver<Bool>
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

        self.deleteButtonItemEnabled = stickerInfo
            .renderedStickerIsNil
            .map { !$0 }
            .startWith(false)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)

        self.imageWithVisibleRect = self.stickerInfo
            .originalImage
            .asDriver()
            .map { (image: UIImage?) -> (UIImage?, CGRect) in
                return (image, stickerInfo.cropBounds.value)
            }

        self.mask = self.stickerInfo
            .mask
            .asDriver()

        self.stickerPlaceholderHidden = self.stickerInfo
            .originalImageIsNil
            .map { !$0 }
            .asDriver(onErrorJustReturn: false)

        let originalImageIsSetToNil = self.stickerInfo
            .originalImageIsNil
            .filter { $0 }
            .map { _ in Void() }

        self.presentImagePicker = Observable
            .of(self.photosButtonItemDidTap, originalImageIsSetToNil)
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

        let stickerWasDeleted = PublishSubject<Void>()

        self.dismissViewController = Observable
            .of(self.cancelButtonItemDidTap, stickerWasSaved, stickerWasDeleted)
            .merge()
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentMainScheduler.instance)

        super.init()

        self.didPickImage
            .filterNil()
            .bindTo(stickerInfo.originalImage)
            .disposed(by: self.disposeBag)

        self.stickerTitleDidChange
            .map { title in
                return title?.trimmingCharacters(in: .whitespaces) ?? ""
            }
            .bindTo(stickerInfo.localizedDescription)
            .disposed(by: self.disposeBag)

        self.visibleRectDidChange
            .bindTo(stickerInfo.cropBounds)
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

        self.deleteButtonItemDidTap
            .withLatestFrom(self.deleteButtonItemEnabled)
            .filter { isEnabled in isEnabled }
            .observeOn(backgroundScheduler)
            .flatMap { _ in
                stickerService.deleteSticker(withUUID: stickerInfo.uuid).asDriver(onErrorJustReturn: Void())
            }
            .bindTo(stickerWasDeleted)
            .disposed(by: self.disposeBag)
    }
}
