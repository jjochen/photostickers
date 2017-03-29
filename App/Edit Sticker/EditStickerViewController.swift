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

    var maskPath: UIBezierPath? {
        didSet {
            updateMask()
        }
    }

    fileprivate let didEndDecelerating = PublishSubject<Void>()
    fileprivate let didEndDraggingWithoutDecelaration = PublishSubject<Void>()
    fileprivate let scrollViewDidMove = PublishSubject<Void>()
}

// MASK: - UIViewController override
extension EditStickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBindings()
        self.configureLayoutConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.maskView.frame = self.blurView.bounds
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
        return self.imageView
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

        self.deleteButtonItem.rx.tap
            .bindTo(viewModel.deleteButtonItemDidTap)
            .disposed(by: self.disposeBag)

        self.photosButtonItem.rx.tap
            .bindTo(viewModel.photosButtonItemDidTap)
            .disposed(by: self.disposeBag)

        self.scrollView.rx
            .didEndDecelerating
            .bindTo(self.didEndDecelerating)
            .disposed(by: self.disposeBag)

        self.scrollView.rx
            .didEndDragging.filter { willDecelerate in
                return !willDecelerate
            }
            .map { _ in Void() }
            .bindTo(self.didEndDraggingWithoutDecelaration)
            .disposed(by: self.disposeBag)

        Observable
            .of(self.didEndDraggingWithoutDecelaration, self.didEndDecelerating)
            .merge()
            .bindTo(self.scrollViewDidMove)
            .disposed(by: self.disposeBag)

        Observable.of(self.scrollViewDidMove, self.rx.viewDidLayoutSubviews)
            .merge()
            .map { _ in self.scrollView.bounds }
            .distinctUntilChanged()
            .bindTo(viewModel.scrollViewBoundsDidChange)
            .disposed(by: self.disposeBag)

        self.rx.viewDidLayoutSubviews
            .map {
                return self.maskView.bounds
            }
            .distinctUntilChanged()
            .bindTo(viewModel.maskViewBoundsDidChange)
            .disposed(by: self.disposeBag)

        self.stickerTitleTextField.rx.text
            .bindTo(viewModel.stickerTitleDidChange)
            .disposed(by: self.disposeBag)

        self.stickerTitleTextField.text = viewModel.stickerTitle
        self.stickerTitleTextField.placeholder = viewModel.stickerTitlePlaceholder

        viewModel.saveButtonItemEnabled
            .drive(self.saveButtonItem.rx.isEnabled)
            .disposed(by: self.disposeBag)

        viewModel.deleteButtonItemEnabled
            .drive(self.deleteButtonItem.rx.isEnabled)
            .disposed(by: self.disposeBag)

        viewModel.stickerPlaceholderHidden
            .drive(self.stickerPlaceholder.rx.isHidden)
            .disposed(by: self.disposeBag)

        viewModel.image
            .drive(self.imageView.rx.image)
            .disposed(by: self.disposeBag)

        viewModel.contentInset
            .drive(self.scrollView.rx.contentInset)
            .disposed(by: self.disposeBag)

        viewModel.maximumZoomScale
            .drive(self.scrollView.rx.maximumZoomScale)
            .disposed(by: self.disposeBag)

        viewModel.minimumZoomScale
            .drive(self.scrollView.rx.minimumZoomScale)
            .disposed(by: self.disposeBag)

        viewModel.zoomScale
            .drive(self.scrollView.rx.zoomScale)
            .disposed(by: self.disposeBag)

        viewModel.contentOffset
            .drive(self.scrollView.rx.contentOffset)
            .disposed(by: self.disposeBag)

        viewModel.maskPath
            .drive(self.rx.maskPath)
            .disposed(by: self.disposeBag)

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
            .disposed(by: self.disposeBag)

        viewModel.dismiss
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .addDisposableTo(self.disposeBag)
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

    func updateMask() {
        guard let path = self.maskPath else {
            return
        }

        self.maskLayer.path = path.cgPath
        self.maskView.layer.mask = self.maskLayer
        self.blurView.mask = self.maskView
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

// MARK: - Rx
fileprivate extension Reactive where Base: EditStickerViewController {

    var maskPath: UIBindingObserver<Base, UIBezierPath> {
        return UIBindingObserver(UIElement: self.base) { UIElement, value in
            UIElement.maskPath = value
        }
    }
}
