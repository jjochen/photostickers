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
import RxFlow
import RxOptional
import RxSwift

final class EditStickerViewModel: ServicesViewModel, Stepper {
    typealias Services = AppServices
    var services: AppServices!

    let steps = PublishRelay<Step>()

    private let backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)

    struct Input {
        let saveButtonItemDidTap: Driver<Void>
        let cancelButtonItemDidTap: Driver<Void>
        let deleteButtonItemDidTap: Driver<Void>
        let photosButtonItemDidTap: Driver<Void>
        let circleButtonDidTap: Driver<Void>
        let rectangleButtonDidTap: Driver<Void>
        let starButtonDidTap: Driver<Void>
        let multiStarButtonDidTap: Driver<Void>
        let didPickImage: Driver<UIImage>
        let visibleRectDidChange: Driver<CGRect>
        let viewDidLayoutSubviews: Driver<Void>
        let stickerTitleDidChange: Driver<String?>
        let deleteAlertDidConfirm: Driver<Void>
        let imageSourceAlertDidSelect: Driver<UIImagePickerController.SourceType>
    }

    struct Output {
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
        let setCropInfo: Driver<UIImage>
        let setTitle: Driver<String?>
        let setCropBounds: Driver<CGRect>
        let setRenderedSticker: Driver<UIImage>
        let setMask: Driver<Mask>
        let dismiss: Driver<Void>
    }

    private let sticker: Sticker
    init(withSticker sticker: Sticker) {
        self.sticker = sticker
    }

    lazy var stickerInfo: StickerInfo = {
        StickerInfo(uuid: sticker.uuid,
                    title: sticker.title,
                    originalImage: sticker.originalImage,
                    renderedSticker: sticker.renderedImage,
                    cropBounds: sticker.cropBounds,
                    mask: sticker.mask,
                    sortOrder: sticker.sortOrder)
    }()

    func transform(input: Input) -> Output {
        let stickerTitlePlaceholder = Sticker.titlePlaceholder
        let stickerTitle = stickerInfo.initialTitle

        let _originalImageWasSetToNil = stickerInfo
            .originalImageIsNil
            .asDriver(onErrorJustReturn: true)
            .filter { $0 }
            .map { _ in Void() }

        let _stickerWasRendered = stickerInfo
            .renderedSticker
            .asDriver()
            .skip(1)
            .map { _ in Void() }

        let _stickerWasSaved = _stickerWasRendered
            .flatMap {
                self.services.stickerService.storeSticker(withInfo: self.stickerInfo).asDriver(onErrorDriveWith: Driver.empty())
                // TODO: use showErrorMessageDriver
            }
            .map { _ in Void() }

        let saveButtonItemEnabled = Observable
            .combineLatest(stickerInfo.originalImageIsNil, stickerInfo.cropBoundsAreEmpty) { !$0 && !$1 }
            .startWith(false)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)

        let deleteButtonItemEnabled = stickerInfo
            .renderedStickerIsNil
            .map { !$0 }
            .startWith(false)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)

        let stickerPlaceholderHidden = stickerInfo
            .originalImageIsNil
            .map { !$0 }
            .startWith(true)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)

        let coverViewHidden = stickerPlaceholderHidden
            .map { !$0 }

        let image = stickerInfo.originalImage
            .asDriver()

        let visibleRect = Driver.of(input.viewDidLayoutSubviews,
                                    stickerInfo.originalImage.asDriver().map { _ in Void() })
            .merge()
            .withLatestFrom(stickerInfo.cropBounds.asDriver())
            .filter { !$0.isEmpty }
            .asDriver()

        let _shouldSelectImage = Driver.of(input.photosButtonItemDidTap,
                                           _originalImageWasSetToNil)
            .merge()

        let availableTypes: [UIImagePickerController.SourceType] = [.camera, .photoLibrary]
            .filter { sourceType in
                UIImagePickerController.isSourceTypeAvailable(sourceType) || UIDevice.isSimulator
            }

        let presentImageSourceAlert: Driver<[UIImagePickerController.SourceType]>
        let presentImagePicker: Driver<UIImagePickerController.SourceType>
        if availableTypes.count > 1 {
            presentImageSourceAlert = _shouldSelectImage
                .map { availableTypes }
            presentImagePicker = input.imageSourceAlertDidSelect
        } else if let sourceType = availableTypes.first {
            presentImageSourceAlert = Driver.empty()
            presentImagePicker = _shouldSelectImage
                .map { sourceType }
        } else {
            Logger.shared.error("No UIImagePickerControllerSourceType available")
            presentImageSourceAlert = Driver.empty()
            presentImagePicker = Driver.empty()
        }

        let presentDeleteAlert = input.deleteButtonItemDidTap
            .withLatestFrom(deleteButtonItemEnabled)
            .filter { isEnabled in isEnabled }
            .map { _ in Void() }

        let _stickerWasDeleted = input.deleteAlertDidConfirm.asObservable()
            .observeOn(backgroundScheduler)
            .flatMap { _ in
                self.services.stickerService.deleteSticker(withUUID: self.stickerInfo.uuid)
            }

        let dismiss = Driver
            .of(input.cancelButtonItemDidTap,
                _stickerWasSaved,
                _stickerWasDeleted.asDriver(onErrorDriveWith: Driver.empty()))
            .merge()
            .do(onNext: {
                self.steps.accept(PhotoStickerStep.editStickerComplete)
            })

        let mask = Driver.of(input.viewDidLayoutSubviews,
                             stickerInfo.mask.asDriver().map { _ in Void() })
            .merge()
            .withLatestFrom(stickerInfo.mask.asDriver())

        let circleButtonSelected = stickerInfo.mask
            .asDriver()
            .map { $0 == .circle }
            .distinctUntilChanged()

        let rectangleButtonSelected = stickerInfo.mask
            .asDriver()
            .map { $0 == .rectangle }
            .distinctUntilChanged()

        let multiStarButtonSelected = stickerInfo.mask
            .asDriver()
            .map { $0 == .multiStar }
            .distinctUntilChanged()

        let starButtonSelected = stickerInfo.mask
            .asDriver()
            .map { $0 == .star }
            .distinctUntilChanged()

        let transparent = input.visibleRectDidChange.asObservable()
            .map { _ in (true, false) }

        let opaque = input.visibleRectDidChange.asObservable()
            .debounce(1, scheduler: MainScheduler.asyncInstance)
            .map { _ in (false, true) }

        let coverViewTransparentAnimated = Observable
            .of(transparent, opaque)
            .merge()
            .startWith((false, false))
            .distinctUntilChanged { lhs, rhs in
                lhs.0 == rhs.0 && lhs.1 == lhs.1
            }
            .asDriver(onErrorJustReturn: (false, false))

        let setCropInfo = input.didPickImage
            .do(onNext: { image in
                var initialRect = CGRect()
                let imageSize = image.size
                let sideLength = imageSize.minSideLength
                initialRect.size.width = sideLength
                initialRect.size.height = sideLength
                initialRect.origin.x = (imageSize.width - sideLength) / 2
                initialRect.origin.y = (imageSize.height - sideLength) / 2
                self.stickerInfo.cropBounds.accept(initialRect)
                self.stickerInfo.originalImage.accept(image)
            })

        let setTitle = input.stickerTitleDidChange
            .map { title in
                title?.trimmingCharacters(in: .whitespaces)
            }
            .do(onNext: { self.stickerInfo.title.accept($0) })

        let setCropBounds = input.visibleRectDidChange
            .do(onNext: { self.stickerInfo.cropBounds.accept($0) })

        let setRenderedSticker = input.saveButtonItemDidTap
            .withLatestFrom(saveButtonItemEnabled)
            .filter { isEnabled in isEnabled }
            .asObservable()
            .observeOn(backgroundScheduler)
            .flatMap { _ in
                self.services.stickerRenderService.render(self.stickerInfo)
            }
            .filterNil()
            .do(onNext: { self.stickerInfo.renderedSticker.accept($0) })
            .asDriver(onErrorDriveWith: Driver.empty())

        let setMask = Driver
            .of(input.circleButtonDidTap.map { Mask.circle },
                input.rectangleButtonDidTap.map { Mask.rectangle },
                input.starButtonDidTap.map { Mask.star },
                input.multiStarButtonDidTap.map { Mask.multiStar })
            .merge()
            .do(onNext: { self.stickerInfo.mask.accept($0) })

        return Output(stickerTitlePlaceholder: stickerTitlePlaceholder,
                      stickerTitle: stickerTitle,
                      saveButtonItemEnabled: saveButtonItemEnabled,
                      deleteButtonItemEnabled: deleteButtonItemEnabled,
                      stickerPlaceholderHidden: stickerPlaceholderHidden,
                      coverViewHidden: coverViewHidden,
                      circleButtonSelected: circleButtonSelected,
                      rectangleButtonSelected: rectangleButtonSelected,
                      multiStarButtonSelected: multiStarButtonSelected,
                      starButtonSelected: starButtonSelected,
                      image: image,
                      visibleRect: visibleRect,
                      mask: mask,
                      coverViewTransparentAnimated: coverViewTransparentAnimated,
                      presentImagePicker: presentImagePicker,
                      presentDeleteAlert: presentDeleteAlert,
                      presentImageSourceAlert: presentImageSourceAlert,
                      setCropInfo: setCropInfo,
                      setTitle: setTitle,
                      setCropBounds: setCropBounds,
                      setRenderedSticker: setRenderedSticker,
                      setMask: setMask,
                      dismiss: dismiss)
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
