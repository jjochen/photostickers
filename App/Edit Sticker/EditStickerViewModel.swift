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
    var scrollViewBoundsDidChange: PublishSubject<CGRect> { get }
    var maskViewBoundsDidChange: PublishSubject<CGRect> { get }
    var stickerTitleDidChange: PublishSubject<String?> { get }

    var stickerTitlePlaceholder: String { get }
    var stickerTitle: String { get }
    var saveButtonItemEnabled: Driver<Bool> { get }
    var deleteButtonItemEnabled: Driver<Bool> { get }
    var stickerPlaceholderHidden: Driver<Bool> { get }
    var imageWithZoomScaleAndContentOffset: Driver<(UIImage?, CGFloat, CGPoint)> { get }
    var zoomScaleAndContentOffset: Driver<(CGFloat, CGPoint)> { get }
    var contentInset: Driver<UIEdgeInsets> { get }
    var maximumZoomScale: Driver<CGFloat> { get }
    var minimumZoomScale: Driver<CGFloat> { get }
    var maskPath: Driver<UIBezierPath> { get }
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
    let didPickImage = PublishSubject<UIImage?>()
    let scrollViewBoundsDidChange = PublishSubject<CGRect>()
    let maskViewBoundsDidChange = PublishSubject<CGRect>()
    let stickerTitleDidChange = PublishSubject<String?>()

    // MARK: Output
    let stickerTitlePlaceholder: String
    let stickerTitle: String
    let saveButtonItemEnabled: Driver<Bool>
    let deleteButtonItemEnabled: Driver<Bool>
    let stickerPlaceholderHidden: Driver<Bool>
    let imageWithZoomScaleAndContentOffset: Driver<(UIImage?, CGFloat, CGPoint)>
    let zoomScaleAndContentOffset: Driver<(CGFloat, CGPoint)>
    let contentInset: Driver<UIEdgeInsets>
    let maximumZoomScale: Driver<CGFloat>
    let minimumZoomScale: Driver<CGFloat>
    let maskPath: Driver<UIBezierPath>
    let presentImagePicker: Driver<UIImagePickerControllerSourceType>
    let dismiss: Driver<Void>

    // MARK: Internal
    fileprivate let stickerWasDeleted = PublishSubject<Void>()
    fileprivate let maskRect: Driver<CGRect>
    fileprivate let scrollViewBoundsSizeDidChange: Driver<CGSize>
    fileprivate let originalImageWasSetToNil: Driver<Void>
    fileprivate let stickerWasRendered: Driver<Void>
    fileprivate let stickerWasSaved: Driver<Void>
    fileprivate let shouldUpdateImage: Driver<Void>
    fileprivate let shouldUpdateVisibleRect: Driver<Void>
    fileprivate let zoomScale: Driver<CGFloat>
    fileprivate let contentOffset: Driver<CGPoint>

    init(sticker: Sticker,
         imageStoreService: ImageStoreServiceType,
         stickerService: StickerServiceType,
         stickerRenderService: StickerRenderServiceType) {

        let stickerInfo = StickerInfo(sticker: sticker)
        self.stickerInfo = stickerInfo
        self.imageStoreService = imageStoreService
        self.stickerService = stickerService
        self.stickerRenderService = stickerRenderService

        stickerTitlePlaceholder = "Photo Sticker"
        stickerTitle = stickerInfo.localizedDescription.value

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

        scrollViewBoundsSizeDidChange = scrollViewBoundsDidChange
            .map { $0.size }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .zero)

        maskRect = scrollViewBoundsSizeDidChange
            .map { size in
                let boundsMinSideLength = size.minSideLength
                let sideLength = boundsMinSideLength * 0.85
                let inset = (boundsMinSideLength - sideLength) / 2.0
                return CGRect(x: inset, y: inset, width: sideLength, height: sideLength)
            }
            .distinctUntilChanged()

        maskPath = Driver
            .combineLatest(stickerInfo.mask.asDriver(),
                           maskViewBoundsDidChange.asDriver(onErrorJustReturn: .zero),
                           maskRect) { mask, bounds, maskRect in
                return mask.maskPath(in: bounds, maskRect: maskRect)
            }

        contentInset = Driver
            .combineLatest(scrollViewBoundsDidChange.asDriver(onErrorJustReturn: .zero),
                           maskRect) { bounds, maskRect in
                var contentInset = UIEdgeInsets()
                contentInset.top = maskRect.minY
                contentInset.left = maskRect.minX
                contentInset.right = bounds.width - maskRect.maxX
                contentInset.bottom = bounds.height - maskRect.maxY
                return contentInset
            }
            .distinctUntilChanged()

        maximumZoomScale = maskRect
            .map { maskRect in
                let minimumZoomedImageSize = Sticker.renderedSize
                guard minimumZoomedImageSize.width > 0 && minimumZoomedImageSize.height > 0 else {
                    return 1
                }

                let xScale = maskRect.width / minimumZoomedImageSize.width
                let yScale = maskRect.height / minimumZoomedImageSize.height
                let maxScale = min(xScale, yScale)
                return maxScale
            }
            .distinctUntilChanged()

        minimumZoomScale = Driver
            .combineLatest(stickerInfo.originalImage.asDriver(), maskRect) { image, maskRect in
                let imageSize = image?.size ?? .zero
                guard imageSize.width > 0 && imageSize.height > 0 else {
                    return 1
                }

                let xScale = maskRect.width / imageSize.width
                let yScale = maskRect.height / imageSize.height
                let minScale = max(xScale, yScale)
                return minScale
            }
            .distinctUntilChanged()

        shouldUpdateImage = stickerInfo
            .originalImage
            .asDriver()
            .map { _ in Void() }

        shouldUpdateVisibleRect = scrollViewBoundsSizeDidChange
            .map { _ in Void() }

        zoomScale = Driver
            .combineLatest(stickerInfo.cropBounds.asDriver(),
                           maskRect,
                           minimumZoomScale,
                           maximumZoomScale) { maskRect, cropBounds, minimumZoomScale, maximumZoomScale in
                guard cropBounds.width > 0 && cropBounds.height > 0 else {
                    return minimumZoomScale
                }

                let xScale = maskRect.width / cropBounds.width
                let yScale = maskRect.height / cropBounds.height
                var scale = min(xScale, yScale)
                scale = max(scale, minimumZoomScale)
                scale = min(scale, maximumZoomScale)
                return scale
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: 1)

        contentOffset = Driver
            .combineLatest(stickerInfo.cropBounds.asDriver(),
                           maskRect,
                           zoomScale) { maskRect, cropBounds, zoomScale in
                var contentOffset = CGPoint()
                contentOffset.x = cropBounds.minX * zoomScale - maskRect.minX
                contentOffset.y = cropBounds.minY * zoomScale - maskRect.minY
                return contentOffset
            }
            .distinctUntilChanged()
            .debug("contentOffset")

        zoomScaleAndContentOffset = shouldUpdateVisibleRect
            .withLatestFrom(Driver.combineLatest(zoomScale, contentOffset) { ($0, $1) })

        imageWithZoomScaleAndContentOffset = shouldUpdateImage
            .withLatestFrom(Driver.combineLatest(stickerInfo.originalImage.asDriver(), zoomScale, contentOffset) { ($0, $1, $2) })

        originalImageWasSetToNil = stickerInfo
            .originalImageIsNil
            .asDriver(onErrorJustReturn: true)
            .filter { $0 }
            .map { _ in Void() }

        presentImagePicker = Driver
            .of(photosButtonItemDidTap.asDriver(onErrorJustReturn: ()), originalImageWasSetToNil)
            .merge()
            .map {
                return .photoLibrary
            }

        stickerWasRendered = stickerInfo
            .renderedSticker
            .asDriver()
            .skip(1)
            .map { _ in Void() }

        stickerWasSaved = stickerWasRendered
            .flatMap {
                return stickerService.storeSticker(withInfo: stickerInfo).asDriver(onErrorDriveWith: Driver.empty())
                // TODO: use showErrorMessageDriver
            }
            .map { _ in Void() }

        dismiss = Driver
            .of(cancelButtonItemDidTap.asDriver(onErrorJustReturn: ()), stickerWasSaved, stickerWasDeleted.asDriver(onErrorJustReturn: ()))
            .merge()

        super.init()

        didPickImage
            .filterNil()
            .bindTo(stickerInfo.originalImage)
            .disposed(by: disposeBag)

        stickerTitleDidChange
            .map { title in
                return title?.trimmingCharacters(in: .whitespaces) ?? ""
            }
            .bindTo(stickerInfo.localizedDescription)
            .disposed(by: disposeBag)

        Driver
            .combineLatest(scrollViewBoundsDidChange.asDriver(onErrorJustReturn: .zero), maskRect) { bounds, maskRect in
                var cropBounds = bounds.offsetBy(dx: maskRect.minX, dy: maskRect.minY)
                cropBounds.size = maskRect.size
                return cropBounds
            }
            .drive(stickerInfo.cropBounds)
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
            .bindTo(stickerWasDeleted)
            .disposed(by: disposeBag)
    }
}
