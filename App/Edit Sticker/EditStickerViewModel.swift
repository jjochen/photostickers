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
    var circleButtonDidTap: PublishSubject<Void> { get }
    var rectangleButtonDidTap: PublishSubject<Void> { get }
    var starButtonDidTap: PublishSubject<Void> { get }
    var multiStarButtonDidTap: PublishSubject<Void> { get }
    var didPickImage: PublishSubject<UIImage?> { get }
    var visibleRectDidChange: PublishSubject<CGRect> { get }
    var viewDidLayoutSubviews: PublishSubject<Void> { get }
    var viewWillTransitionToSize: PublishSubject<CGSize> { get }
    var stickerTitleDidChange: PublishSubject<String?> { get }

    var stickerTitlePlaceholder: String { get }
    var stickerTitle: String? { get }
    var saveButtonItemEnabled: Driver<Bool> { get }
    var deleteButtonItemEnabled: Driver<Bool> { get }
    var stickerPlaceholderHidden: Driver<Bool> { get }
    var circleButtonSelected: Driver<Bool> { get }
    var rectangleButtonSelected: Driver<Bool> { get }
    var multiStarButtonSelected: Driver<Bool> { get }
    var starButtonSelected: Driver<Bool> { get }
    var image: Driver<UIImage?> { get }
    var visibleRect: Driver<CGRect> { get }
    var mask: Driver<Mask> { get }
    var coverViewTransparentAnimated: Driver<(Bool, Bool)> { get }
    var presentImagePicker: Driver<UIImagePickerControllerSourceType> { get }
    var dismiss: Driver<Void> { get }
}

class EditStickerViewModel: BaseViewModel, EditStickerViewModelType {

    let disposeBag = DisposeBag()
    let backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)

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
    let circleButtonDidTap = PublishSubject<Void>()
    let rectangleButtonDidTap = PublishSubject<Void>()
    let starButtonDidTap = PublishSubject<Void>()
    let multiStarButtonDidTap = PublishSubject<Void>()
    let didPickImage = PublishSubject<UIImage?>()
    let visibleRectDidChange = PublishSubject<CGRect>()
    let viewDidLayoutSubviews = PublishSubject<Void>()
    let viewWillTransitionToSize = PublishSubject<CGSize>()
    let stickerTitleDidChange = PublishSubject<String?>()

    // MARK: Output
    let stickerTitlePlaceholder: String
    let stickerTitle: String?
    let saveButtonItemEnabled: Driver<Bool>
    let deleteButtonItemEnabled: Driver<Bool>
    let stickerPlaceholderHidden: Driver<Bool>
    let circleButtonSelected: Driver<Bool>
    let rectangleButtonSelected: Driver<Bool>
    let multiStarButtonSelected: Driver<Bool>
    let starButtonSelected: Driver<Bool>
    let image: Driver<UIImage?>
    let visibleRect: Driver<CGRect>
    let mask: Driver<Mask>
    let coverViewTransparentAnimated: Driver<(Bool, Bool)>
    let presentImagePicker: Driver<UIImagePickerControllerSourceType>
    let dismiss: Driver<Void>

    // MARK: Internal
    fileprivate let _stickerWasDeleted = PublishSubject<Void>()
    fileprivate let _originalImageWasSetToNil: Driver<Void>
    fileprivate let _stickerWasRendered: Driver<Void>
    fileprivate let _stickerWasSaved: Driver<Void>

    init(sticker: Sticker,
         imageStoreService: ImageStoreServiceType,
         stickerService: StickerServiceType,
         stickerRenderService: StickerRenderServiceType) {

        let stickerInfo = StickerInfo(sticker: sticker)
        self.stickerInfo = stickerInfo
        self.imageStoreService = imageStoreService
        self.stickerService = stickerService
        self.stickerRenderService = stickerRenderService

        stickerTitlePlaceholder = Sticker.titlePlaceholder
        stickerTitle = stickerInfo.initialTitle

        _originalImageWasSetToNil = stickerInfo
            .originalImageIsNil
            .asDriver(onErrorJustReturn: true)
            .filter { $0 }
            .map { _ in Void() }

        _stickerWasRendered = stickerInfo
            .renderedSticker
            .asDriver()
            .skip(1)
            .map { _ in Void() }

        _stickerWasSaved = _stickerWasRendered
            .flatMap {
                return stickerService.storeSticker(withInfo: stickerInfo).asDriver(onErrorDriveWith: Driver.empty())
                // TODO: use showErrorMessageDriver
            }
            .map { _ in Void() }

        saveButtonItemEnabled = Observable
            .combineLatest(stickerInfo.originalImageIsNil, stickerInfo.cropBoundsAreEmpty) { !$0 && !$1 }
            .startWith(false)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)

        deleteButtonItemEnabled = stickerInfo
            .renderedStickerIsNil
            .map { !$0 }
            .startWith(false)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)

        stickerPlaceholderHidden = stickerInfo
            .originalImageIsNil
            .map { !$0 }
            .startWith(true)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)

        image = stickerInfo.originalImage
            .asDriver()

        let cropBounds = Observable
            .combineLatest(stickerInfo.cropBounds.asObservable(),
                           stickerInfo.originalImage.asObservable())
            .map { cropBounds, originalImage -> CGRect in
                guard let image = originalImage else {
                    return CGRect.zero
                }

                guard !cropBounds.isEmpty && !cropBounds.isNull else {
                    var initialRect = CGRect()
                    let imageSize = image.size
                    let sideLength = imageSize.minSideLength
                    initialRect.size.width = sideLength
                    initialRect.size.height = sideLength
                    initialRect.origin.x = (imageSize.width - sideLength) / 2
                    initialRect.origin.y = (imageSize.height - sideLength) / 2
                    return initialRect
                }

                return cropBounds
            }
            .filter { !$0.isEmpty }

        visibleRect = viewDidLayoutSubviews
            .withLatestFrom(cropBounds)
            .asDriver(onErrorDriveWith: Driver.empty())

        presentImagePicker = Driver
            .of(photosButtonItemDidTap.asDriver(onErrorJustReturn: ()),
                _originalImageWasSetToNil)
            .merge()
            .map {
                return .photoLibrary
            }

        dismiss = Driver
            .of(cancelButtonItemDidTap.asDriver(onErrorJustReturn: ()),
                _stickerWasSaved,
                _stickerWasDeleted.asDriver(onErrorJustReturn: ()))
            .merge()

        mask = Observable.of(viewDidLayoutSubviews,
                             stickerInfo.mask.asObservable().map { _ in Void() })
            .merge()
            .withLatestFrom(stickerInfo.mask.asObservable())
            .asDriver(onErrorJustReturn: .circle)

        circleButtonSelected = stickerInfo.mask
            .asDriver()
            .map { $0 == .circle }
            .distinctUntilChanged()

        rectangleButtonSelected = stickerInfo.mask
            .asDriver()
            .map { $0 == .rectangle }
            .distinctUntilChanged()

        multiStarButtonSelected = stickerInfo.mask
            .asDriver()
            .map { $0 == .multiStar }
            .distinctUntilChanged()

        starButtonSelected = stickerInfo.mask
            .asDriver()
            .map { $0 == .star }
            .distinctUntilChanged()

        let transparent = visibleRectDidChange
            .map { _ in (true, false) }

        let opaque = visibleRectDidChange
            .debounce(1, scheduler: MainScheduler.asyncInstance)
            .map { _ in (false, true) }

        coverViewTransparentAnimated = Observable
            .of(transparent, opaque)
            .merge()
            .startWith((false, false))
            .distinctUntilChanged { lhs, rhs in
                lhs.0 == rhs.0 && lhs.1 == lhs.1
            }
            .asDriver(onErrorJustReturn: (false, false))

        super.init()

        didPickImage
            .filterNil()
            .bindTo(stickerInfo.originalImage)
            .disposed(by: disposeBag)

        stickerTitleDidChange
            .map { title in
                return title?.trimmingCharacters(in: .whitespaces)
            }
            .bindTo(stickerInfo.title)
            .disposed(by: disposeBag)

        visibleRectDidChange
            .bindTo(stickerInfo.cropBounds)
            .disposed(by: disposeBag)

        saveButtonItemDidTap
            .withLatestFrom(saveButtonItemEnabled)
            .filter { isEnabled in isEnabled }
            .observeOn(backgroundScheduler)
            .flatMap { _ in
                return stickerRenderService.render(stickerInfo)
            }
            .filterNil()
            .bindTo(stickerInfo.renderedSticker)
            .disposed(by: disposeBag)

        deleteButtonItemDidTap
            .withLatestFrom(deleteButtonItemEnabled)
            .filter { isEnabled in isEnabled }
            .observeOn(backgroundScheduler)
            .flatMap { _ in
                stickerService.deleteSticker(withUUID: stickerInfo.uuid)
            }
            .bindTo(_stickerWasDeleted)
            .disposed(by: disposeBag)

        Observable
            .of(circleButtonDidTap.map { Mask.circle },
                rectangleButtonDidTap.map { Mask.rectangle },
                starButtonDidTap.map { Mask.star },
                multiStarButtonDidTap.map { Mask.multiStar })
            .merge()
            .bindTo(stickerInfo.mask)
            .disposed(by: disposeBag)
    }
}
