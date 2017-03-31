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

    fileprivate let didEndDecelerating = PublishSubject<Void>()
    fileprivate let didEndDraggingWithoutDecelaration = PublishSubject<Void>()
}

// MASK: - UIViewController override
extension EditStickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        configureLayoutConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        maskView.frame = blurView.bounds
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

        Observable
            .of(didEndDraggingWithoutDecelaration,
                didEndDecelerating)
            .merge()
            .map { self.scrollView.contentOffset }
            .bindTo(viewModel.contentOffsetDidChange)
            .disposed(by: disposeBag)

        scrollView.rx.didZoom
            .map { self.scrollView.zoomScale }
            .bindTo(viewModel.zoomScaleDidChange)
            .disposed(by: disposeBag)

        Observable.of(scrollView.rx.didZoom.map { _ in Void() },
                      didEndDraggingWithoutDecelaration,
                      didEndDecelerating,
                      rx.viewDidLayoutSubviews)
            .merge()
            .map { self.scrollView.bounds }
            .distinctUntilChanged()
            .bindTo(viewModel.scrollViewBoundsDidChange)
            .disposed(by: disposeBag)

        rx.viewDidLayoutSubviews
            .map {
                return self.maskView.bounds
            }
            .distinctUntilChanged()
            .bindTo(viewModel.maskViewBoundsDidChange)
            .disposed(by: disposeBag)

        stickerTitleTextField.rx.text
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

        viewModel.contentInset
            .drive(scrollView.rx.contentInset)
            .disposed(by: disposeBag)

        viewModel.maximumZoomScale
            .drive(scrollView.rx.maximumZoomScale)
            .disposed(by: disposeBag)

        viewModel.minimumZoomScale
            .drive(scrollView.rx.minimumZoomScale)
            .disposed(by: disposeBag)

        viewModel.zoomScaleAndContentOffset
            .drive(onNext: { zoomScale, contentOffset in
                self.scrollView.zoomScale = zoomScale
                self.scrollView.contentOffset = contentOffset
            })
            .disposed(by: disposeBag)

        viewModel.imageWithZoomScaleAndContentOffset
            .drive(onNext: { image, zoomScale, contentOffset in
                self.scrollView.zoomScale = 1
                self.scrollView.contentOffset = .zero
                self.imageView.image = image
                self.scrollView.contentSize = image?.size ?? .zero
                self.scrollView.zoomScale = zoomScale
                self.scrollView.contentOffset = contentOffset

                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            })
            .disposed(by: disposeBag)

        viewModel.maskPath
            .drive(onNext: { path in
                self.maskLayer.path = path.cgPath
                self.maskView.layer.mask = self.maskLayer
                self.blurView.mask = self.maskView
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
                return info[UIImagePickerControllerOriginalImage] as? UIImage
            }
            .drive(viewModel.didPickImage)
            .disposed(by: disposeBag)

        viewModel.dismiss
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .addDisposableTo(disposeBag)
    }
}

// MARK: - Configuration
fileprivate extension EditStickerViewController {
    //    func configure() {
    //        guard let configuration = self.configuration else {
    //            return
    //        }
    //
    //        self.scrollView.zoomScale = 1
    //        self.imageView.image = configuration.image
    //        self.scrollView.contentSize = configuration.image?.size ?? .zero
    //
    //        self.scrollView.contentInset = configuration.contentInset
    //        self.scrollView.minimumZoomScale = configuration.minimumZoomScale
    //        self.scrollView.maximumZoomScale = configuration.maximumZoomScale
    //        self.scrollView.zoomScale = configuration.zoomScale
    //        self.scrollView.contentOffset = configuration.contentOffset
    //
    //        self.view.setNeedsLayout()
    //        self.view.layoutIfNeeded()
    //    }
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
