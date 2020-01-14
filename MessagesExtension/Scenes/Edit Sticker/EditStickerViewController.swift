//
//  EditStickerViewController.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 23/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Reusable
import RxCocoa
import RxOptional
import RxSwift
import RxViewController
import UIKit

class EditStickerViewController: UIViewController, StoryboardBased, ViewModelBased {
    var viewModel: EditStickerViewModel!
    private let disposeBag = DisposeBag()

    @IBOutlet var saveButtonItem: UIBarButtonItem!
    @IBOutlet var cancelButtonItem: UIBarButtonItem!
    @IBOutlet var photosButtonItem: UIBarButtonItem!
    @IBOutlet var deleteButtonItem: UIBarButtonItem!
    @IBOutlet var scrollView: ImageScrollView!
    @IBOutlet var stickerPlaceholder: AppIconView!
    @IBOutlet var coverView: MaskView!
    @IBOutlet var stickerTitleTextField: UITextField!
    @IBOutlet var circleButton: UIButton!
    @IBOutlet var rectangleButton: UIButton!
    @IBOutlet var starButton: UIButton!
    @IBOutlet var multiStarButton: UIButton!
    @IBOutlet var portraitConstraints: [NSLayoutConstraint]!
    @IBOutlet var landscapeConstraints: [NSLayoutConstraint]!
}

// MASK: - UIViewController override
extension EditStickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        view.tintColor = StyleKit.appColor
        coverView.delegate = self
        setupButtons()
        setupBindings()
        configureLayoutConstraints()
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

// MARK: - Bindings

private extension EditStickerViewController {
    func setupBindings() {
        guard let viewModel = self.viewModel else {
            fatalError("View Model not set!")
        }

        let _deleteAlertRelay = PublishRelay<Void>()
        let deleteAlertDidConfirm = _deleteAlertRelay.asDriver(onErrorDriveWith: Driver.empty())

        let _imageSourceAlertRelay = PublishRelay<UIImagePickerController.SourceType>()
        let imageSourceAlertDidSelect = _imageSourceAlertRelay.asDriver(onErrorDriveWith: Driver.empty())

        let viewDidLayoutSubviews = rx.viewDidLayoutSubviews.asDriver()

        let saveButtonItemDidTap = saveButtonItem.rx.tap.asDriver()

        let cancelButtonItemDidTap = cancelButtonItem.rx.tap.asDriver()

        let deleteButtonItemDidTap = deleteButtonItem.rx.tap.asDriver()

        let photosButtonItemDidTap = photosButtonItem.rx.tap.asDriver()

        let circleButtonDidTap = circleButton.rx.tap.asDriver()

        let rectangleButtonDidTap = rectangleButton.rx.tap.asDriver()

        let starButtonDidTap = starButton.rx.tap.asDriver()

        let multiStarButtonDidTap = multiStarButton.rx.tap.asDriver()

        let _didPickImage = PublishSubject<UIImage>()
        let didPickImage = _didPickImage.asDriver(onErrorDriveWith: Driver.empty())

        // TODO:
        let visibleRectDidChange = Driver.empty()
            .filter { _ in
                self.scrollView.image != nil
            }
            .map { self.scrollView.visibleRect }

        let stickerTitleDidChange = stickerTitleTextField.rx.text
            .asDriver()
            .skip(1)

        let input = ViewModelType.Input(saveButtonItemDidTap: saveButtonItemDidTap,
                                        cancelButtonItemDidTap: cancelButtonItemDidTap,
                                        deleteButtonItemDidTap: deleteButtonItemDidTap,
                                        photosButtonItemDidTap: photosButtonItemDidTap,
                                        circleButtonDidTap: circleButtonDidTap,
                                        rectangleButtonDidTap: rectangleButtonDidTap,
                                        starButtonDidTap: starButtonDidTap,
                                        multiStarButtonDidTap: multiStarButtonDidTap,
                                        didPickImage: didPickImage,
                                        visibleRectDidChange: visibleRectDidChange,
                                        viewDidLayoutSubviews: viewDidLayoutSubviews,
                                        stickerTitleDidChange: stickerTitleDidChange,
                                        deleteAlertDidConfirm: deleteAlertDidConfirm,
                                        imageSourceAlertDidSelect: imageSourceAlertDidSelect)

        let output = viewModel.transform(input: input)

        stickerTitleTextField.text = output.stickerTitle
        stickerTitleTextField.placeholder = output.stickerTitlePlaceholder

        output.saveButtonItemEnabled
            .drive(saveButtonItem.rx.isEnabled)
            .disposed(by: disposeBag)

        output.deleteButtonItemEnabled
            .drive(deleteButtonItem.rx.isEnabled)
            .disposed(by: disposeBag)

        output.stickerPlaceholderHidden
            .drive(stickerPlaceholder.rx.isHidden)
            .disposed(by: disposeBag)

        output.coverViewHidden
            .drive(coverView.rx.isHidden)
            .disposed(by: disposeBag)

        output.circleButtonSelected
            .drive(circleButton.rx.isSelected)
            .disposed(by: disposeBag)

        output.rectangleButtonSelected
            .drive(rectangleButton.rx.isSelected)
            .disposed(by: disposeBag)

        output.multiStarButtonSelected
            .drive(multiStarButton.rx.isSelected)
            .disposed(by: disposeBag)

        output.starButtonSelected
            .drive(starButton.rx.isSelected)
            .disposed(by: disposeBag)

        output.visibleRect
            .drive(onNext: { [weak self] rect in
                guard let self = self else { return }
                self.scrollView.visibleRect = rect
            })
            .disposed(by: disposeBag)

        output.image
            .drive(onNext: { [unowned self] image in
                self.scrollView.image = image
            })
            .disposed(by: disposeBag)

        output.mask
            .drive(onNext: { [unowned self] mask in
                self.coverView.maskType = mask
            })
            .disposed(by: disposeBag)

        output.coverViewTransparentAnimated
            .drive(onNext: { [unowned self] transparent, animated in
                self.setCoverView(transparent: transparent, animated: animated)
            })
            .disposed(by: disposeBag)

        output.presentImagePicker
            .filter { sourceType in
                UIImagePickerController.isSourceTypeAvailable(sourceType)
            }
            .flatMapLatest { sourceType in
                UIImagePickerController.rx.createWithParent(self) { picker in
                    picker.sourceType = sourceType
                    picker.allowsEditing = false
                    picker.view.tintColor = StyleKit.appColor
                }
                .flatMap { imagePicker in
                    imagePicker.rx.didFinishPickingMediaWithInfo
                }
                .take(1)
                .asDriver(onErrorJustReturn: [:])
            }
            .map { info -> UIImage? in
                let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
                return image?.fixOrientation()
            }
            .filterNil()
            .drive(_didPickImage)
            .disposed(by: disposeBag)

        output.presentDeleteAlert
            .drive(onNext: { [unowned self] in
                let alertController = UIAlertController(
                    title: nil,
                    message: nil,
                    preferredStyle: .actionSheet
                )

                let deleteAction = UIAlertAction(title: "Delete".localized,
                                                 style: .destructive,
                                                 handler: { _ in
                                                     _deleteAlertRelay.accept(Void())
                })
                alertController.addAction(deleteAction)

                let cancelAction = UIAlertAction(title: "Cancel".localized,
                                                 style: .cancel,
                                                 handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        output.presentImageSourceAlert
            .drive(onNext: { [unowned self] sourceTypes in
                let alertController = UIAlertController(
                    title: nil,
                    message: nil,
                    preferredStyle: .actionSheet
                )
                alertController.accessibilityLabel = "ImageSourceAlert"

                sourceTypes
                    .map { type in
                        var title: String?
                        var accessibilityLabel: String?
                        switch type {
                        case .photoLibrary:
                            title = "ImagePickerSourceTypePhotoLibrary".localized
                            accessibilityLabel = "ImageSourceAlertButtonPhotoLibrary"
                        case .camera:
                            title = "ImagePickerSourceTypeCamera".localized
                            accessibilityLabel = "ImageSourceAlertButtonCamera"
                        default:
                            title = nil
                            accessibilityLabel = nil
                        }

                        let handler: (UIAlertAction) -> Void = { _ in
                            _imageSourceAlertRelay.accept(type)
                        }
                        let action = UIAlertAction(title: title, style: .default, handler: handler)
                        action.accessibilityLabel = accessibilityLabel
                        return action
                    }
                    .forEach(alertController.addAction)

                let cancelAction = UIAlertAction(title: "Cancel".localized,
                                                 style: .cancel,
                                                 handler: nil)
                cancelAction.accessibilityLabel = "ImageSourceAlertButtonCancel"
                alertController.addAction(cancelAction)
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.barButtonItem = self.photosButtonItem
                }
                self.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        output.setCropInfo
            .drive()
            .disposed(by: disposeBag)

        output.setCropBounds
            .drive()
            .disposed(by: disposeBag)

        output.setTitle
            .drive()
            .disposed(by: disposeBag)

        output.setRenderedSticker
            .drive()
            .disposed(by: disposeBag)

        output.setMask
            .drive()
            .disposed(by: disposeBag)

        output.dismiss
            .drive()
            .disposed(by: disposeBag)
    }
}

// MARK: - MaskViewDelegate

extension EditStickerViewController: MaskViewDelegate {
    // TODO: use rxswift
    func maskRect(inMaskView maskView: MaskView) -> CGRect {
        return scrollView.convertBounds(to: maskView)
    }
}

// MARK: - Layout

private extension EditStickerViewController {
    func configureLayoutConstraints() {
        guard let portraitConstraints = self.portraitConstraints else {
            return
        }

        guard let landscapeConstraints = self.landscapeConstraints else {
            return
        }

        view.removeConstraints(portraitConstraints)
        view.removeConstraints(landscapeConstraints)

        if view.bounds.height >= view.bounds.width {
            view.addConstraints(portraitConstraints)
        } else {
            view.addConstraints(landscapeConstraints)
        }

        super.updateViewConstraints()
    }
}

private extension EditStickerViewController {
    func setupButtons() {
        let lineWidth = CGFloat(3)

        circleButton.setTitle(nil, for: UIControl.State())
        circleButton.titleLabel?.isHidden = true
        circleButton.setBackgroundImages { selected, highlighted in
            StyleKit.imageOfCircleButton(lineWidth: lineWidth,
                                         selected: selected,
                                         highlighted: highlighted)
        }

        rectangleButton.setTitle(nil, for: UIControl.State())
        rectangleButton.setBackgroundImages { selected, highlighted in
            StyleKit.imageOfRectangleButton(
                lineWidth: lineWidth,
                selected: selected,
                highlighted: highlighted
            )
        }

        multiStarButton.setTitle(nil, for: UIControl.State())
        multiStarButton.setBackgroundImages { selected, highlighted in
            StyleKit.imageOfMultiStarButton(
                lineWidth: lineWidth,
                selected: selected,
                highlighted: highlighted
            )
        }

        starButton.setTitle(nil, for: UIControl.State())
        starButton.setBackgroundImages { selected, highlighted in
            StyleKit.imageOfStarButton(
                lineWidth: lineWidth,
                selected: selected,
                highlighted: highlighted
            )
        }
    }

    func setCoverView(transparent: Bool, animated: Bool) {
        UIView.animate(withDuration: 0.3, animated: animated) {
            self.coverView.alpha = transparent ? 0.75 : 1
            self.coverView.shadowHidden = transparent
        }
    }
}
