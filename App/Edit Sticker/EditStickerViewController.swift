//
//  EditStickerViewController.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 23/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Log

class EditStickerViewController: UIViewController {

    var viewModel: EditStickerViewModelType?
    fileprivate let disposeBag = DisposeBag()

    @IBOutlet weak var saveButtonItem: UIBarButtonItem!
    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!
    @IBOutlet weak var photosButtonItem: UIBarButtonItem!
    @IBOutlet weak var deleteButtonItem: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stickerPlaceholder: UIImageView!
    @IBOutlet weak var stickerCropView: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var stickerTitleTextField: UITextField!

    @IBOutlet var portraitConstraints: [NSLayoutConstraint]!
    @IBOutlet var landscapeConstraints: [NSLayoutConstraint]!

    fileprivate lazy var maskView: UIView = {
        let maskView = UIView()
        maskView.backgroundColor = UIColor.black
        return maskView
    }()

    fileprivate lazy var maskLayer: CAShapeLayer = {
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = kCAFillRuleEvenOdd
        return maskLayer
    }()

    fileprivate var mask: Mask = .circle
}

extension EditStickerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBindings()
        self.configureLayoutConstraints()
        self.updateMask()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.updateMask()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        coordinator.animate(alongsideTransition: { context in
            self.configureLayoutConstraints()
        },
        completion: { context in

        })
        super.viewWillTransition(to: size, with: coordinator)
    }
}

// MARK: - Bindings
fileprivate extension EditStickerViewController {
    func setupBindings() {
        guard let viewModel = self.viewModel else {
            Logger.shared.error("View Model not set!")
            return
        }

        self.saveButtonItem.rx.tap
            .bindTo(viewModel.saveButtonItemDidTap)
            .disposed(by: self.disposeBag)

        self.cancelButtonItem.rx.tap
            .bindTo(viewModel.cancelButtonItemDidTap)
            .disposed(by: self.disposeBag)

        self.photosButtonItem.rx.tap
            .bindTo(viewModel.photosButtonItemDidTap)
            .disposed(by: self.disposeBag)

        self.deleteButtonItem.rx.tap
            .bindTo(viewModel.deleteButtonItemDidTap)
            .disposed(by: self.disposeBag)

        Observable.of(scrollView.rx.didScroll, scrollView.rx.didZoom)
            .merge()
            .map { () -> CGRect in
                return self.visibleImageRect
            }
            .bindTo(viewModel.visibleRectDidChange)
            .disposed(by: self.disposeBag)

        self.stickerTitleTextField.rx.text
            .bindTo(viewModel.stickerTitleDidChange)
            .disposed(by: self.disposeBag)

        //        // ToDo: Better observe viewWillTransition(to and viewWillApear/Load
        //        Observable.of(self.stickerPlaceholder.rx.observeWeakly(CGRect.self, "bounds").map { _ in Void() },
        //                      self.stickerPlaceholder.rx.observeWeakly(CGPoint.self, "center").map { _ in Void() })
        //            .merge()
        //            .map { _ in
        //                return self.stickerPlaceholder.convertBounds(to: self.imageView)
        //            }
        //            .distinctUntilChanged()
        //            .asDriver(onErrorJustReturn: .zero)
        //            .debug()
        //            .drive(self.imageView.rx.cropRect)
        //            .disposed(by: self.disposeBag)

        viewModel.imageWithVisibleRect
            .asObservable()
            .subscribe(onNext: { image, visibleRect in
                self.setImage(image, visibleRect: visibleRect)
            })
            .disposed(by: self.disposeBag)

        viewModel.mask.asObservable()
            .subscribe(onNext: { mask in
                self.mask = mask
                //                self.updateMask()
            })
            .disposed(by: self.disposeBag)

        viewModel.saveButtonItemEnabled
            .drive(self.saveButtonItem.rx.isEnabled)
            .disposed(by: self.disposeBag)

        viewModel.deleteButtonItemEnabled
            .drive(self.deleteButtonItem.rx.isEnabled)
            .disposed(by: self.disposeBag)

        viewModel.stickerPlaceholderHidden
            .drive(self.stickerPlaceholder.rx.isHidden)
            .disposed(by: self.disposeBag)

        viewModel.presentImagePicker
            .flatMapLatest { [weak self] sourceType in
                return UIImagePickerController.rx.createWithParent(self) { picker in
                    picker.sourceType = sourceType
                    picker.allowsEditing = false
                }
                .flatMap { imagePicker in
                    imagePicker.rx.didFinishPickingMediaWithInfo
                }
                .take(1)
            }
            .map { info in
                return info[UIImagePickerControllerOriginalImage] as? UIImage
            }
            .bindTo(viewModel.didPickImage)
            .disposed(by: self.disposeBag)

        viewModel.dismissViewController
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .addDisposableTo(self.disposeBag)
    }
}

// MARK: - Layout
fileprivate extension EditStickerViewController {
    func updateMask() {

        self.maskView.frame = self.view.bounds
        let bounds = self.maskView.bounds
        let minBoundsSideLength = min(bounds.width, bounds.height)
        let sideLength = minBoundsSideLength * 0.85
        let offset = (minBoundsSideLength - sideLength) / 2
        let maskRect = CGRect(x: offset, y: offset, width: sideLength, height: sideLength)
        let path = self.mask.maskPath(in: bounds, maskRect: maskRect)

        self.maskLayer.path = path.cgPath
        self.maskView.layer.mask = self.maskLayer
        self.blurView.mask = self.maskView
    }

    func configureLayoutConstraints() {

        guard let portraitConstraints = self.portraitConstraints else {
            return
        }

        guard let landscapeConstraints = self.landscapeConstraints else {
            return
        }

        self.view.removeConstraints(portraitConstraints)
        self.view.removeConstraints(landscapeConstraints)

        if UIApplication.shared.statusBarOrientation.isPortrait {
            self.view.addConstraints(portraitConstraints)
        } else {
            self.view.addConstraints(landscapeConstraints)
        }

        super.updateViewConstraints()
    }
}

// MARK: - Helper
fileprivate extension EditStickerViewController {

    var image: UIImage? {
        get {
            return self.imageView.image
        }
        set(image) {
            self.setImage(image)
        }
    }

    var cropSize: CGSize {
        let cropSize = self.stickerCropView.frame.size
        return cropSize
    }

    var cropRect: CGRect {
        var cropRect = self.stickerCropView.convertBounds(to: self.view)
        cropRect.origin.x -= self.scrollView.frame.origin.x
        cropRect.origin.y -= self.scrollView.frame.origin.y
        return cropRect
    }

    var visibleImageRect: CGRect {
        get {
            let visibleRect = self.stickerCropView.convertBounds(to: self.imageView)
            return visibleRect.intersection(self.imageView.bounds)
        }
        set(visibleRect) {
            self.setZoomScale(for: visibleRect)
            self.setContentOffset(for: visibleRect)
        }
    }

    func setImage(_ image: UIImage?, visibleRect: CGRect = .zero) {
        self.imageView.image = image
        self.scrollView.setNeedsLayout()
        self.scrollView.layoutIfNeeded()
        self.configureScrollView(for: visibleRect)
    }

    var imageWithVisibleRect: ImageWithVisibleRect {
        get {
            return ImageWithVisibleRect(image: self.image, visibleRect: self.visibleImageRect)
        }
        set(imageWithVisibleRect) {
            self.setImage(imageWithVisibleRect.image, visibleRect: imageWithVisibleRect.visibleRect)
        }
    }

    var imageSize: CGSize {
        return self.image?.size ?? .zero
    }

    var minimumZoomedImageSize: CGSize {
        return Sticker.renderedSize // !!! make configurable !!!
    }
}

// MARK: - UIScrollView configuration
fileprivate extension EditStickerViewController {
    func configureScrollView(for visibleImageRect: CGRect) {
        self.scrollView.zoomScale = 1 // needed because of some weird scroll view behavior
        self.scrollView.contentOffset = .zero

        self.configureContentInset()
        self.configureMaxMinZoomScales()
        self.visibleImageRect = visibleImageRect
    }

    func configureContentInset() {
        let cropRect = self.cropRect
        let bounds = self.scrollView.bounds
        var insets = UIEdgeInsets()
        insets.left = cropRect.minX
        insets.top = cropRect.minY
        insets.right = bounds.width - cropRect.maxX
        insets.bottom = bounds.height - cropRect.maxY

        self.scrollView.contentInset = insets
    }

    func configureMaxMinZoomScales() {
        let minScale = self.minScale
        let maxScale = self.maxScale

        self.scrollView.maximumZoomScale = max(minScale, maxScale)
        self.scrollView.minimumZoomScale = min(minScale, maxScale)
    }

    func setZoomScale(for visibleImageRect: CGRect) {
        guard visibleImageRect.width > 0 && visibleImageRect.height > 0 else {
            self.scrollView.zoomScale = self.initialZoomScale
            return
        }

        let cropSize = self.cropSize

        let xScale = cropSize.width / visibleImageRect.width
        let yScale = cropSize.height / visibleImageRect.height
        var scale = min(xScale, yScale)
        scale = max(scale, self.minScale)
        scale = min(scale, self.maxScale)

        self.scrollView.zoomScale = scale
    }

    func setContentOffset(for visibleRect: CGRect) {
        let visibleRect = visibleRect.isEmpty ? self.initialVisibleRect : visibleRect
        let scale = self.scrollView.zoomScale
        let cropRectOrigin = self.cropRect.origin // check

        var contentOffset = CGPoint()
        contentOffset.x = visibleRect.minX * scale - cropRectOrigin.x
        contentOffset.y = visibleRect.minY * scale - cropRectOrigin.y

        self.scrollView.contentOffset = contentOffset
    }

    var initialZoomScale: CGFloat {
        return self.minScale
    }

    var initialVisibleRect: CGRect {
        let imageSize = self.imageSize
        let minSideLength = min(imageSize.width, imageSize.height)

        var visibleRect = CGRect()
        visibleRect.size = imageSize
        visibleRect.origin.x = (imageSize.width - minSideLength) / 2.0
        visibleRect.origin.y = (imageSize.height - minSideLength) / 2.0

        return visibleRect
    }

    var minScale: CGFloat {
        let cropSize = self.cropSize
        let imageSize = self.imageSize

        guard imageSize.width > 0 && imageSize.height > 0 else {
            return 1
        }

        let xScale = cropSize.width / imageSize.width
        let yScale = cropSize.height / imageSize.height
        let minScale = max(xScale, yScale)
        return minScale
    }

    var maxScale: CGFloat {
        let cropSize = self.cropSize
        let minimumZoomedImageSize = self.minimumZoomedImageSize

        guard minimumZoomedImageSize.width > 0 && minimumZoomedImageSize.height > 0 else {
            return 1
        }

        let xScale = cropSize.width / minimumZoomedImageSize.width
        let yScale = cropSize.height / minimumZoomedImageSize.height
        let maxScale = min(xScale, yScale)
        return maxScale
    }
}

// MARK: - UIScrollViewDelegate
extension EditStickerViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
