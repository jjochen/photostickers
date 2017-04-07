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
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var stickerTitleTextField: UITextField!

    @IBOutlet weak var circleButton: UIButton!
    @IBOutlet weak var rectangleButton: UIButton!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var multiStarButton: UIButton!

    @IBOutlet var portraitConstraints: [NSLayoutConstraint]!
    @IBOutlet var landscapeConstraints: [NSLayoutConstraint]!

    fileprivate lazy var maskLayer: CAShapeLayer = {
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = kCAFillRuleEvenOdd
        return maskLayer
    }()

    fileprivate lazy var shadowLayer: CAShapeLayer = {
        let shadowLayer = CAShapeLayer()
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOpacity = 1
        shadowLayer.shadowOffset = CGSize(width: 0, height: 3)
        shadowLayer.shadowRadius = 6
        return shadowLayer
    }()

    fileprivate let didEndDecelerating = PublishSubject<Void>()
    fileprivate let didEndDraggingWithoutDecelaration = PublishSubject<Void>()
    fileprivate let didZoom = PublishSubject<Void>()
    fileprivate let didScroll = PublishSubject<Void>()
}

// MASK: - UIViewController override
extension EditStickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        coverView.layer.addSublayer(shadowLayer)
        setupButtons()
        setupBindings()
        configureLayoutConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        maskLayer.frame = coverView.bounds
        shadowLayer.frame = coverView.bounds
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            self.configureLayoutConstraints()
        },
        completion: { _ in
        })
        super.viewWillTransition(to: size, with: coordinator)
    }
}

// MARK: - UIScrollViewDelegate
extension EditStickerViewController: UIScrollViewDelegate {
    func viewForZooming(in _: UIScrollView) -> UIView? {
        return imageView
    }
}

// MARK: - Bindings
fileprivate extension EditStickerViewController {
    func setupBindings() {
        guard let viewModel = self.viewModel else {
            Logger.shared.error("View Model not set!")
            return
        }

        rx.viewDidLayoutSubviews
            .bindTo(viewModel.viewDidLayoutSubviews)
            .disposed(by: disposeBag)

        rx.viewWillTransitionToSize
            .bindTo(viewModel.viewWillTransitionToSize)
            .disposed(by: disposeBag)

        saveButtonItem.rx.tap
            .bindTo(viewModel.saveButtonItemDidTap)
            .disposed(by: disposeBag)

        cancelButtonItem.rx.tap
            .bindTo(viewModel.cancelButtonItemDidTap)
            .disposed(by: disposeBag)

        deleteButtonItem.rx.tap
            .bindTo(viewModel.deleteButtonItemDidTap)
            .disposed(by: disposeBag)

        photosButtonItem.rx.tap
            .bindTo(viewModel.photosButtonItemDidTap)
            .disposed(by: disposeBag)

        circleButton.rx.tap
            .bindTo(viewModel.circleButtonDidTap)
            .disposed(by: disposeBag)

        rectangleButton.rx.tap
            .bindTo(viewModel.rectangleButtonDidTap)
            .disposed(by: disposeBag)

        starButton.rx.tap
            .bindTo(viewModel.starButtonDidTap)
            .disposed(by: disposeBag)

        multiStarButton.rx.tap
            .bindTo(viewModel.multiStarButtonDidTap)
            .disposed(by: disposeBag)

        scrollView.rx
            .didEndDecelerating
            .bindTo(didEndDecelerating)
            .disposed(by: disposeBag)

        scrollView.rx
            .didEndDragging.filter { willDecelerate in
                return !willDecelerate
            }
            .map { _ in Void() }
            .bindTo(didEndDraggingWithoutDecelaration)
            .disposed(by: disposeBag)

        scrollView.rx
            .didScroll
            .filter { _ in
                return self.scrollView.isDragging || self.scrollView.isDecelerating
            }
            .bindTo(didScroll)
            .disposed(by: disposeBag)

        scrollView.rx
            .didZoom
            .filter { _ in
                return self.scrollView.isZooming || self.scrollView.isZoomBouncing
            }
            .bindTo(didZoom)
            .disposed(by: disposeBag)

        Observable
            .of(didScroll,
                didZoom)
            .merge()
            .filter { _ in
                return self.imageView.image != nil
            }
            .map { self.visibleRect }
            .bindTo(viewModel.visibleRectDidChange)
            .disposed(by: disposeBag)

        stickerTitleTextField.rx.text
            .skip(1)
            .bindTo(viewModel.stickerTitleDidChange)
            .disposed(by: disposeBag)

        stickerTitleTextField.text = viewModel.stickerTitle
        stickerTitleTextField.placeholder = viewModel.stickerTitlePlaceholder

        viewModel.saveButtonItemEnabled
            .drive(saveButtonItem.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.deleteButtonItemEnabled
            .drive(deleteButtonItem.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.stickerPlaceholderHidden
            .drive(stickerPlaceholder.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.circleButtonSelected
            .drive(circleButton.rx.isSelected)
            .disposed(by: disposeBag)

        viewModel.rectangleButtonSelected
            .drive(rectangleButton.rx.isSelected)
            .disposed(by: disposeBag)

        viewModel.multiStarButtonSelected
            .drive(multiStarButton.rx.isSelected)
            .disposed(by: disposeBag)

        viewModel.starButtonSelected
            .drive(starButton.rx.isSelected)
            .disposed(by: disposeBag)

        viewModel.visibleRect
            .drive(onNext: { rect in
                self.scrollView.zoomScale = self.zoomScale(for: rect)
                self.scrollView.contentOffset = self.contentOffset(for: rect)
            })
            .disposed(by: disposeBag)

        viewModel.image
            .drive(onNext: { image in
                self.scrollView.zoomScale = 1
                self.scrollView.contentOffset = .zero
                self.imageView.image = image
                self.scrollView.contentSize = image?.size ?? .zero

                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()

                self.scrollView.minimumZoomScale = self.minimumZoomScale
                self.scrollView.maximumZoomScale = self.maximumZoomScale
            })
            .disposed(by: disposeBag)

        viewModel.mask
            .drive(onNext: { mask in
                let maskRect = self.scrollView.convertBounds(to: self.coverView)
                let maskPath = mask.maskPath(in: self.coverView.bounds, maskRect: maskRect)
                self.maskLayer.path = maskPath.cgPath
                self.coverView.layer.mask = self.maskLayer

                let shadowPath = mask.path(in: maskRect)
                self.shadowLayer.shadowPath = shadowPath.cgPath

            })
            .disposed(by: disposeBag)

        viewModel.coverViewTransparentAnimated
            .drive(onNext: { transparent, animated in
                if animated {
                    UIView.beginAnimations("CoverViewAlpha", context: nil)
                    UIView.setAnimationDuration(0.3)
                }
                self.coverView.alpha = transparent ? 0.75 : 1
                self.shadowLayer.isHidden = transparent
                if animated {
                    UIView.commitAnimations()
                }
            })
            .disposed(by: disposeBag)

        viewModel.presentImagePicker
            .flatMapLatest { sourceType in
                return UIImagePickerController.rx.createWithParent(self) { picker in
                    picker.sourceType = sourceType
                    picker.allowsEditing = false
                }
                .flatMap { imagePicker in
                    imagePicker.rx.didFinishPickingMediaWithInfo
                }
                .take(1)
                .asDriver(onErrorJustReturn: [:])
            }
            .map { info in
                let image = info[UIImagePickerControllerOriginalImage] as? UIImage
                return image?.fixOrientation()
            }
            .filter { $0 != nil }
            .drive(viewModel.didPickImage)
            .disposed(by: disposeBag)

        viewModel.dismiss
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .addDisposableTo(disposeBag)
    }
}

// MARK: - Layout
fileprivate extension EditStickerViewController {

    func configureLayoutConstraints() {

        guard let portraitConstraints = self.portraitConstraints else {
            return
        }

        guard let landscapeConstraints = self.landscapeConstraints else {
            return
        }

        view.removeConstraints(portraitConstraints)
        view.removeConstraints(landscapeConstraints)

        if UIApplication.shared.statusBarOrientation.isPortrait {
            view.addConstraints(portraitConstraints)
        } else {
            view.addConstraints(landscapeConstraints)
        }

        super.updateViewConstraints()
    }
}

fileprivate extension EditStickerViewController {
    func setupButtons() {
        let lineWidth = CGFloat(2)

        circleButton.setTitle(nil, for: UIControlState())
        circleButton.titleLabel?.isHidden = true
        circleButton.setBackgroundImages { selected, highlighted in
            return StyleKit.imageOfCircleButton(lineWidth: lineWidth,
                                                selected: selected,
                                                highlighted: highlighted)
        }

        rectangleButton.setTitle(nil, for: UIControlState())
        rectangleButton.setBackgroundImages { selected, highlighted in
            return StyleKit.imageOfRectangleButton(lineWidth: lineWidth,
                                                   selected: selected,
                                                   highlighted: highlighted)
        }

        multiStarButton.setTitle(nil, for: UIControlState())
        multiStarButton.setBackgroundImages { selected, highlighted in
            return StyleKit.imageOfMultiStarButton(lineWidth: lineWidth,
                                                   selected: selected,
                                                   highlighted: highlighted)
        }

        starButton.setTitle(nil, for: UIControlState())
        starButton.setBackgroundImages { selected, highlighted in
            return StyleKit.imageOfStarButton(lineWidth: lineWidth,
                                              selected: selected,
                                              highlighted: highlighted)
        }
    }
}

fileprivate extension EditStickerViewController {

    var minimumZoomedImageSize: CGSize { //
        return Sticker.renderedSize
    }

    var imageSize: CGSize {
        return imageView.image?.size ?? .zero
    }

    var visibleRect: CGRect {
        return scrollView.convertBounds(to: imageView)
    }

    var maximumZoomScale: CGFloat {
        let minimumZoomedImageSize = self.minimumZoomedImageSize
        let boundsSize = scrollView.bounds.size

        guard minimumZoomedImageSize.width > 0 && minimumZoomedImageSize.height > 0 else {
            return 1
        }

        let xScale = boundsSize.width / minimumZoomedImageSize.width
        let yScale = boundsSize.height / minimumZoomedImageSize.height
        let maxScale = min(xScale, yScale)
        return maxScale
    }

    var minimumZoomScale: CGFloat {
        let imageSize = self.imageSize
        let boundsSize = scrollView.bounds.size

        guard imageSize.width > 0 && imageSize.height > 0 else {
            return 1
        }

        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let minScale = max(xScale, yScale)
        return minScale
    }
}

fileprivate extension EditStickerViewController {
    func zoomScale(for visibleRect: CGRect) -> CGFloat {
        let boundsSize = scrollView.bounds.size
        let visibleRectSize = visibleRect.size

        guard visibleRectSize.width > 0 && visibleRectSize.height > 0 else {
            return 1
        }

        let xScale = boundsSize.width / visibleRectSize.width
        let yScale = boundsSize.height / visibleRectSize.height
        let zoomScale = min(xScale, yScale)
        return zoomScale
    }

    func contentOffset(for visibleRect: CGRect) -> CGPoint {
        let zoomScale = self.zoomScale(for: visibleRect)
        var offset = visibleRect.origin
        offset.x *= zoomScale
        offset.y *= zoomScale
        return offset
    }
}
