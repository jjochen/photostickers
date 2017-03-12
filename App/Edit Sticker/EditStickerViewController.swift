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
    @IBOutlet weak var imageView: ImageScrollView!
    @IBOutlet weak var maskView: MaskView!

    @IBOutlet var portraitConstraints: [NSLayoutConstraint]!
    @IBOutlet var landscapeConstraints: [NSLayoutConstraint]!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.minimumZoomedImageSize = Sticker.renderedSize
        self.setupBindings()
        self.configureLayoutConstraints()
    }

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

        self.imageView.rx.visibleRect
            .bindTo(viewModel.didZoomToVisibleRect)
            .disposed(by: self.disposeBag)

        viewModel.originalImageWithBounds
            .map { image, bounds in
                return ImageWithVisibleRect(image: image, visibleRect: bounds)
            }
            .drive(self.imageView.rx.imageWithVisibleRect)
            .disposed(by: self.disposeBag)

        viewModel.mask
            .map { mask in
                return mask.path(in: self.maskView.bounds)
            }
            .drive(self.maskView.rx.path)
            .disposed(by: self.disposeBag)

        viewModel.saveButtonItemEnabled
            .drive(self.saveButtonItem.rx.isEnabled)
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

extension EditStickerViewController {

    fileprivate func configureLayoutConstraints() {

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

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        coordinator.animate(alongsideTransition: { context in
            self.configureLayoutConstraints()
        },
        completion: { context in

        })
        super.viewWillTransition(to: size, with: coordinator)
    }
}
