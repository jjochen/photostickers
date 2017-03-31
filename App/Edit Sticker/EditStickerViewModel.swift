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
    var zoomScaleDidChange: PublishSubject<CGFloat> { get }
    var contentOffsetDidChange: PublishSubject<CGPoint> { get }
    var scrollViewBoundsDidChange: PublishSubject<CGRect> { get }
    var maskViewBoundsDidChange: PublishSubject<CGRect> { get }
    var viewDidTransitionToSize: PublishSubject<CGSize> { get }
    var stickerTitleDidChange: PublishSubject<String?> { get }

    var stickerTitlePlaceholder: String { get }
    var stickerTitle: String? { get }
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
    let zoomScaleDidChange = PublishSubject<CGFloat>()
    let contentOffsetDidChange = PublishSubject<CGPoint>()
    let scrollViewBoundsDidChange = PublishSubject<CGRect>()
    let maskViewBoundsDidChange = PublishSubject<CGRect>()
    let viewDidTransitionToSize = PublishSubject<CGSize>()
    let stickerTitleDidChange = PublishSubject<String?>()

    // MARK: Output
    let stickerTitlePlaceholder: String
    let stickerTitle: String?
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
    fileprivate let _stickerWasDeleted = PublishSubject<Void>()

    fileprivate let _imageSize: Driver<CGSize>
    fileprivate let _scrollViewBoundsSize: Driver<CGSize>

    fileprivate let _viewDidTransition: Driver<Void>
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

        _scrollViewBoundsSize = scrollViewBoundsDidChange
            .map { $0.size }
            .startWith(.zero)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .zero)

        _imageSize = self.stickerInfo
            .originalImage
            .asDriver()
            .map { $0?.size ?? .zero }
            .distinctUntilChanged()

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

        _viewDidTransition = viewDidTransitionToSize
            .startWith(.zero)
            .map { _ in Void() }
            .asDriver(onErrorDriveWith: Driver.empty())

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

        maskPath = Driver
            .combineLatest(stickerInfo.mask.asDriver(),
                           maskViewBoundsDidChange.asDriver(onErrorJustReturn: .zero),
                           _viewDidTransition) { mask, maskViewBounds, _ in
                let maskRect = EditStickerViewModel.maskRect(boundsSize: maskViewBounds.size)
                return mask.maskPath(in: maskViewBounds, maskRect: maskRect)
            }

        contentInset = _scrollViewBoundsSize
            .map { boundsSize in
                return EditStickerViewModel.contentInset(boundsSize: boundsSize)
            }
            .distinctUntilChanged()

        maximumZoomScale = _scrollViewBoundsSize
            .map { size in
                return EditStickerViewModel.maximumZoomScale(boundsSize: size)
            }
            .distinctUntilChanged()

        minimumZoomScale = Driver
            .combineLatest(_imageSize, _scrollViewBoundsSize) { imageSize, boundsSize in
                return EditStickerViewModel.minimumZoomScale(imageSize: imageSize, boundsSize: boundsSize)
            }
            .distinctUntilChanged()

        zoomScaleAndContentOffset = _scrollViewBoundsSize
            .withLatestFrom(
                Driver.combineLatest(_imageSize,
                                     _scrollViewBoundsSize,
                                     stickerInfo.cropBounds.asDriver()) { imageSize, boundsSize, cropBounds in
                    EditStickerViewModel.zoomScaleAndContentOffset(imageSize: imageSize, boundsSize: boundsSize, cropBounds: cropBounds)
            })

        imageWithZoomScaleAndContentOffset = stickerInfo.originalImage
            .asDriver()
            .withLatestFrom(
                Driver.combineLatest(stickerInfo.originalImage.asDriver(),
                                     _scrollViewBoundsSize,
                                     stickerInfo.cropBounds.asDriver()) { image, boundsSize, cropBounds in
                    let imageSize = image?.size ?? .zero
                    let (zoomScale, contentOffset) = EditStickerViewModel.zoomScaleAndContentOffset(imageSize: imageSize, boundsSize: boundsSize, cropBounds: cropBounds)
                    return (image, zoomScale, contentOffset)
            })

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

        Driver
            .combineLatest(zoomScaleDidChange.asDriver(onErrorJustReturn: 1),
                           contentOffsetDidChange.asDriver(onErrorJustReturn: .zero),
                           _scrollViewBoundsSize) { zoomScale, contentOffset, boundsSize in
                return EditStickerViewModel.cropBounds(boundsSize: boundsSize, zoomScale: zoomScale, contentOffset: contentOffset)
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
            .bindTo(_stickerWasDeleted)
            .disposed(by: disposeBag)
    }
}

fileprivate extension EditStickerViewModel {

    static func maskRect(boundsSize: CGSize) -> CGRect {
        let boundsMinSideLength = boundsSize.minSideLength
        let sideLength = boundsMinSideLength * 0.85
        let inset = (boundsMinSideLength - sideLength) / 2.0
        return CGRect(x: inset, y: inset, width: sideLength, height: sideLength)
    }

    static func contentInset(boundsSize: CGSize) -> UIEdgeInsets {
        let maskRect = self.maskRect(boundsSize: boundsSize)
        var contentInset = UIEdgeInsets()
        contentInset.top = maskRect.minY
        contentInset.left = maskRect.minX
        contentInset.right = boundsSize.width - maskRect.maxX
        contentInset.bottom = boundsSize.height - maskRect.maxY
        return contentInset
    }

    static func maximumZoomScale(boundsSize: CGSize) -> CGFloat {
        let minimumZoomedImageSize = self.minimumZoomedImageSize()
        guard minimumZoomedImageSize.width > 0 && minimumZoomedImageSize.height > 0 else {
            return 1
        }

        let maskRect = self.maskRect(boundsSize: boundsSize)
        let xScale = maskRect.width / minimumZoomedImageSize.width
        let yScale = maskRect.height / minimumZoomedImageSize.height
        let maxScale = min(xScale, yScale)
        return maxScale
    }

    static func minimumZoomScale(imageSize: CGSize, boundsSize: CGSize) -> CGFloat {
        guard imageSize.width > 0 && imageSize.height > 0 else {
            return 1
        }

        let maskRect = self.maskRect(boundsSize: boundsSize)
        let xScale = maskRect.width / imageSize.width
        let yScale = maskRect.height / imageSize.height
        let minScale = max(xScale, yScale)
        return minScale
    }

    static func zoomScaleAndContentOffset(imageSize: CGSize, boundsSize: CGSize, cropBounds: CGRect) -> (CGFloat, CGPoint) {
        let minimumZoomScale = self.minimumZoomScale(imageSize: imageSize, boundsSize: boundsSize)
        let maximumZoomScale = self.maximumZoomScale(boundsSize: boundsSize)

        let maskRect = self.maskRect(boundsSize: boundsSize)

        var cropBounds = cropBounds
        if cropBounds.isEmpty {
            cropBounds = initialCropBounds(imageSize: imageSize)
        }

        var zoomScale: CGFloat
        if cropBounds.width > 0 && cropBounds.height > 0 {
            let xScale = maskRect.width / cropBounds.width
            let yScale = maskRect.height / cropBounds.height
            zoomScale = min(xScale, yScale)
        } else {
            zoomScale = 1
        }

        zoomScale = max(zoomScale, minimumZoomScale)
        zoomScale = min(zoomScale, maximumZoomScale)

        var contentOffset = CGPoint() // ToDo Check!
        contentOffset.x = cropBounds.minX * zoomScale - maskRect.minX
        contentOffset.y = cropBounds.minY * zoomScale - maskRect.minY

        return (zoomScale, contentOffset)
    }

    static func initialCropBounds(imageSize: CGSize) -> CGRect {
        let minSideLength = min(imageSize.width, imageSize.height)

        var cropBounds = CGRect()
        cropBounds.size.width = minSideLength
        cropBounds.size.height = minSideLength
        cropBounds.origin.x = (imageSize.width - minSideLength) / 2.0
        cropBounds.origin.y = (imageSize.height - minSideLength) / 2.0

        return cropBounds
    }

    static func cropBounds(boundsSize: CGSize, zoomScale: CGFloat, contentOffset: CGPoint) -> CGRect {
        guard zoomScale > 0 else {
            return .zero
        }

        let maskRect = self.maskRect(boundsSize: boundsSize)
        var cropBounds = CGRect()
        cropBounds.origin.x = (contentOffset.x + maskRect.minX) / zoomScale
        cropBounds.origin.y = (contentOffset.y + maskRect.minY) / zoomScale
        cropBounds.size.width = maskRect.width / zoomScale
        cropBounds.size.height = maskRect.height / zoomScale
        return cropBounds
    }

    static func minimumZoomedImageSize() -> CGSize {
        return Sticker.renderedSize
    }
}
