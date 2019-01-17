//
//  EditStickerViewModel.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 23/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import Log
import RxCocoa
import RxSwift

protocol EditStickerViewModelType: class {
    func maximumZoomScale(imageSize: CGSize, boundsSize: CGSize) -> CGFloat
    func minimumZoomScale(imageSize: CGSize, boundsSize: CGSize) -> CGFloat
    func zoomScale(visibleRect: CGRect, boundsSize: CGSize) -> CGFloat
    func contentOffset(visibleRect: CGRect, boundsSize: CGSize) -> CGPoint

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
    var deleteAlertDidConfirm: PublishSubject<Void> { get }
    var imageSourceAlertDidSelect: PublishSubject<UIImagePickerController.SourceType> { get }

    var stickerTitlePlaceholder: String { get }
    var stickerTitle: String? { get }
    var saveButtonItemEnabled: Driver<Bool> { get }
    var deleteButtonItemEnabled: Driver<Bool> { get }
    var stickerPlaceholderHidden: Driver<Bool> { get }
    var coverViewHidden: Driver<Bool> { get }
    var circleButtonSelected: Driver<Bool> { get }
    var rectangleButtonSelected: Driver<Bool> { get }
    var multiStarButtonSelected: Driver<Bool> { get }
    var starButtonSelected: Driver<Bool> { get }
    var image: Driver<UIImage?> { get }
    var visibleRect: Driver<CGRect> { get }
    var mask: Driver<Mask> { get }
    var coverViewTransparentAnimated: Driver<(Bool, Bool)> { get }
    var presentImagePicker: Driver<UIImagePickerController.SourceType> { get }
    var presentDeleteAlert: Driver<Void> { get }
    var presentImageSourceAlert: Driver<[UIImagePickerController.SourceType]> { get }
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
    let deleteAlertDidConfirm = PublishSubject<Void>()
    let imageSourceAlertDidSelect = PublishSubject<UIImagePickerController.SourceType>()

    // MARK: Output

    let stickerTitlePlaceholder: String
    let stickerTitle: String?
    let saveButtonItemEnabled: Driver<Bool>
    let deleteButtonItemEnabled: Driver<Bool>
    let stickerPlaceholderHidden: Driver<Bool>
    let coverViewHidden: Driver<Bool>
    let circleButtonSelected: Driver<Bool>
    let rectangleButtonSelected: Driver<Bool>
    let multiStarButtonSelected: Driver<Bool>
    let starButtonSelected: Driver<Bool>
    let image: Driver<UIImage?>
    let visibleRect: Driver<CGRect>
    let mask: Driver<Mask>
    let coverViewTransparentAnimated: Driver<(Bool, Bool)>
    let presentImagePicker: Driver<UIImagePickerController.SourceType>
    let presentDeleteAlert: Driver<Void>
    let presentImageSourceAlert: Driver<[UIImagePickerController.SourceType]>
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
        let stickerInfo = StickerInfo(uuid: sticker.uuid,
                                      title: sticker.title,
                                      originalImage: sticker.originalImage(from: imageStoreService),
                                      renderedSticker: sticker.renderedImage(from: imageStoreService),
                                      cropBounds: sticker.cropBounds,
                                      mask: sticker.mask,
                                      sortOrder: sticker.sortOrder)
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

        coverViewHidden = stickerPlaceholderHidden
            .map { !$0 }

        image = stickerInfo.originalImage
            .asDriver()

        visibleRect = Observable.of(viewDidLayoutSubviews,
                                    stickerInfo.originalImage.asObservable().map { _ in Void() })
            .merge()
            .withLatestFrom(stickerInfo.cropBounds.asObservable())
            .filter { !$0.isEmpty }
            .asDriver(onErrorDriveWith: Driver.empty())

        let _shouldSelectImage = Driver
            .of(photosButtonItemDidTap.asDriver(onErrorDriveWith: Driver.empty()),
                _originalImageWasSetToNil)
            .merge()

        let availableTypes: [UIImagePickerController.SourceType] = [.camera, .photoLibrary]
            .filter { sourceType in
                return UIImagePickerController.isSourceTypeAvailable(sourceType) || UIDevice.isSimulator
            }

        if availableTypes.count > 1 {
            presentImageSourceAlert = _shouldSelectImage
                .map { availableTypes }
            presentImagePicker = imageSourceAlertDidSelect
                .asDriver(onErrorDriveWith: Driver.empty())
        } else if let sourceType = availableTypes.first {
            presentImageSourceAlert = Driver.empty()
            presentImagePicker = _shouldSelectImage
                .map { sourceType }
        } else {
            Logger.shared.error("No UIImagePickerControllerSourceType available")
            presentImageSourceAlert = Driver.empty()
            presentImagePicker = Driver.empty()
        }

        presentDeleteAlert = deleteButtonItemDidTap
            .withLatestFrom(deleteButtonItemEnabled)
            .filter { isEnabled in isEnabled }
            .map { _ in Void() }
            .asDriver(onErrorDriveWith: Driver.empty())

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
            .subscribe(onNext: { image in
                var initialRect = CGRect()
                let imageSize = image.size
                let sideLength = imageSize.minSideLength
                initialRect.size.width = sideLength
                initialRect.size.height = sideLength
                initialRect.origin.x = (imageSize.width - sideLength) / 2
                initialRect.origin.y = (imageSize.height - sideLength) / 2
                self.stickerInfo.cropBounds.value = initialRect
                self.stickerInfo.originalImage.value = image
            })
            .disposed(by: disposeBag)

        stickerTitleDidChange
            .map { title in
                return title?.trimmingCharacters(in: .whitespaces)
            }
            .bind(to: stickerInfo.title)
            .disposed(by: disposeBag)

        visibleRectDidChange
            .bind(to: stickerInfo.cropBounds)
            .disposed(by: disposeBag)

        saveButtonItemDidTap
            .withLatestFrom(saveButtonItemEnabled)
            .filter { isEnabled in isEnabled }
            .observeOn(backgroundScheduler)
            .flatMap { _ in
                return stickerRenderService.render(stickerInfo)
            }
            .filterNil()
            .bind(to: stickerInfo.renderedSticker)
            .disposed(by: disposeBag)

        deleteAlertDidConfirm
            .observeOn(backgroundScheduler)
            .flatMap { _ in
                stickerService.deleteSticker(withUUID: stickerInfo.uuid)
            }
            .bind(to: _stickerWasDeleted)
            .disposed(by: disposeBag)

        Observable
            .of(circleButtonDidTap.map { Mask.circle },
                rectangleButtonDidTap.map { Mask.rectangle },
                starButtonDidTap.map { Mask.star },
                multiStarButtonDidTap.map { Mask.multiStar })
            .merge()
            .bind(to: stickerInfo.mask)
            .disposed(by: disposeBag)
    }
}

extension EditStickerViewModel {
    func minimumZoomedSize(forImageSize imageSize: CGSize) -> CGSize {
        let minSideLength = imageSize.minSideLength
        var minimumZoomedSize = CGSize()
        minimumZoomedSize.width = min(minSideLength, Sticker.renderedSize.width)
        minimumZoomedSize.height = min(minSideLength, Sticker.renderedSize.height)
        return minimumZoomedSize
    }

    func maximumZoomScale(imageSize: CGSize, boundsSize: CGSize) -> CGFloat {
        let minimumZoomedSize = self.minimumZoomedSize(forImageSize: imageSize)
        guard minimumZoomedSize.width > 0, minimumZoomedSize.height > 0 else {
            return 1
        }

        let xScale = boundsSize.width / minimumZoomedSize.width
        let yScale = boundsSize.height / minimumZoomedSize.height
        let maxScale = min(xScale, yScale)
        return maxScale
    }

    func minimumZoomScale(imageSize: CGSize, boundsSize: CGSize) -> CGFloat {
        guard imageSize.width > 0, imageSize.height > 0 else {
            return 1
        }

        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let minScale = max(xScale, yScale)
        return minScale
    }
}

extension EditStickerViewModel {
    func zoomScale(visibleRect: CGRect, boundsSize: CGSize) -> CGFloat {
        let visibleRectSize = visibleRect.size

        guard visibleRectSize.width > 0, visibleRectSize.height > 0 else {
            return 1
        }

        let xScale = boundsSize.width / visibleRectSize.width
        let yScale = boundsSize.height / visibleRectSize.height
        let zoomScale = min(xScale, yScale)
        return zoomScale
    }

    func contentOffset(visibleRect: CGRect, boundsSize: CGSize) -> CGPoint {
        let zoomScale = self.zoomScale(visibleRect: visibleRect, boundsSize: boundsSize)
        var offset = visibleRect.origin
        offset.x *= zoomScale
        offset.y *= zoomScale
        return offset
    }
}
