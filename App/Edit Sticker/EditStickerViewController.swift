//
//  EditStickerViewController.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 23/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Log
import RxCocoa
import RxSwift
import UIKit

class EditStickerViewController: UIViewController {
    var viewModel: EditStickerViewModelType?
    fileprivate let disposeBag = DisposeBag()

    @IBOutlet var saveButtonItem: UIBarButtonItem!
    @IBOutlet var cancelButtonItem: UIBarButtonItem!
    @IBOutlet var photosButtonItem: UIBarButtonItem!
    @IBOutlet var deleteButtonItem: UIBarButtonItem!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var stickerPlaceholder: AppIconView!
    @IBOutlet var coverView: UIView!
    @IBOutlet var stickerTitleTextField: UITextField!

    @IBOutlet var circleButton: UIButton!
    @IBOutlet var rectangleButton: UIButton!
    @IBOutlet var starButton: UIButton!
    @IBOutlet var multiStarButton: UIButton!

    @IBOutlet var portraitConstraints: [NSLayoutConstraint]!
    @IBOutlet var landscapeConstraints: [NSLayoutConstraint]!

    fileprivate lazy var maskLayer: CAShapeLayer = {
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
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
            .bind(to: viewModel.viewDidLayoutSubviews)
            .disposed(by: disposeBag)

        rx.viewWillTransitionToSize
            .bind(to: viewModel.viewWillTransitionToSize)
            .disposed(by: disposeBag)

        saveButtonItem.rx.tap
            .bind(to: viewModel.saveButtonItemDidTap)
            .disposed(by: disposeBag)

        cancelButtonItem.rx.tap
            .bind(to: viewModel.cancelButtonItemDidTap)
            .disposed(by: disposeBag)

        deleteButtonItem.rx.tap
            .bind(to: viewModel.deleteButtonItemDidTap)
            .disposed(by: disposeBag)

        photosButtonItem.rx.tap
            .bind(to: viewModel.photosButtonItemDidTap)
            .disposed(by: disposeBag)

        circleButton.rx.tap
            .bind(to: viewModel.circleButtonDidTap)
            .disposed(by: disposeBag)

        rectangleButton.rx.tap
            .bind(to: viewModel.rectangleButtonDidTap)
            .disposed(by: disposeBag)

        starButton.rx.tap
            .bind(to: viewModel.starButtonDidTap)
            .disposed(by: disposeBag)

        multiStarButton.rx.tap
            .bind(to: viewModel.multiStarButtonDidTap)
            .disposed(by: disposeBag)

        scrollView.rx
            .didEndDecelerating
            .bind(to: didEndDecelerating)
            .disposed(by: disposeBag)

        scrollView.rx
            .didEndDragging.filter { willDecelerate in
                return !willDecelerate
            }
            .map { _ in Void() }
            .bind(to: didEndDraggingWithoutDecelaration)
            .disposed(by: disposeBag)

        scrollView.rx
            .didScroll
            .filter { _ in
                return self.scrollView.isDragging || self.scrollView.isDecelerating
            }
            .bind(to: didScroll)
            .disposed(by: disposeBag)

        scrollView.rx
            .didZoom
            .filter { _ in
                return self.scrollView.isZooming || self.scrollView.isZoomBouncing
            }
            .bind(to: didZoom)
            .disposed(by: disposeBag)

        Observable
            .of(didScroll,
                didZoom)
            .merge()
            .filter { _ in
                return self.imageView.image != nil
            }
            .map { self.visibleRect }
            .bind(to: viewModel.visibleRectDidChange)
            .disposed(by: disposeBag)

        stickerTitleTextField.rx.text
            .skip(1)
            .bind(to: viewModel.stickerTitleDidChange)
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

        viewModel.coverViewHidden
            .drive(coverView.rx.isHidden)
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
            .drive(onNext: { [weak self, weak viewModel] rect in
                guard let `self` = self, let viewModel = viewModel else { return }
                let boundsSize = self.scrollView.bounds.size
                self.scrollView.zoomScale = viewModel.zoomScale(visibleRect: rect, boundsSize: boundsSize)
                self.scrollView.contentOffset = viewModel.contentOffset(visibleRect: rect, boundsSize: boundsSize)
            })
            .disposed(by: disposeBag)

        viewModel.image
            .drive(onNext: { [weak self, weak viewModel] image in
                guard let `self` = self, let viewModel = viewModel else { return }
                let imageSize = image?.size ?? .zero
                self.scrollView.zoomScale = 1
                self.scrollView.contentOffset = .zero
                self.imageView.image = image
                self.scrollView.contentSize = imageSize

                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()

                let boundsSize = self.scrollView.bounds.size
                self.scrollView.minimumZoomScale = viewModel.minimumZoomScale(imageSize: imageSize, boundsSize: boundsSize)
                self.scrollView.maximumZoomScale = viewModel.maximumZoomScale(imageSize: imageSize, boundsSize: boundsSize)
            })
            .disposed(by: disposeBag)

        viewModel.mask
            .drive(onNext: { [weak self] mask in
                guard let `self` = self else { return }
                let maskRect = self.scrollView.convertBounds(to: self.coverView)
                let maskPath = mask.maskPath(in: self.coverView.bounds, maskRect: maskRect)
                self.maskLayer.path = maskPath.cgPath
                self.coverView.layer.mask = self.maskLayer

                let shadowPath = mask.path(in: maskRect)
                self.shadowLayer.shadowPath = shadowPath.cgPath
            })
            .disposed(by: disposeBag)

        viewModel.coverViewTransparentAnimated
            .drive(onNext: { [weak self] transparent, animated in
                guard let `self` = self else { return }
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
            .filter { sourceType in
                return UIImagePickerController.isSourceTypeAvailable(sourceType)
            }
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
                let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
                return image?.fixOrientation()
            }
            .filter { $0 != nil }
            .drive(viewModel.didPickImage)
            .disposed(by: disposeBag)

        viewModel.presentDeleteAlert
            .drive(onNext: { [weak self, weak viewModel] in
                guard let `self` = self, let viewModel = viewModel else { return }
                let alertController = UIAlertController(
                    title: nil,
                    message: nil,
                    preferredStyle: .actionSheet
                )

                let deleteAction = UIAlertAction(title: "Delete".localized,
                                                 style: .destructive,
                                                 handler: { _ in
                                                     viewModel.deleteAlertDidConfirm.onNext(())
                })
                alertController.addAction(deleteAction)

                let cancelAction = UIAlertAction(title: "Cancel".localized,
                                                 style: .cancel,
                                                 handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        viewModel.presentImageSourceAlert
            .drive(onNext: { [weak self, weak viewModel] sourceTypes in
                guard let `self` = self, let viewModel = viewModel else { return }

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
                            break
                        case .camera:
                            title = "ImagePickerSourceTypeCamera".localized
                            accessibilityLabel = "ImageSourceAlertButtonCamera"
                            break
                        default:
                            title = nil
                            accessibilityLabel = nil
                            break
                        }

                        let handler: (UIAlertAction) -> Void = { _ in
                            viewModel.imageSourceAlertDidSelect.onNext(type)
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

        viewModel.dismiss
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
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
        let lineWidth = CGFloat(3)

        circleButton.setTitle(nil, for: UIControl.State())
        circleButton.titleLabel?.isHidden = true
        circleButton.setBackgroundImages { selected, highlighted in
            return StyleKit.imageOfCircleButton(lineWidth: lineWidth,
                                                selected: selected,
                                                highlighted: highlighted)
        }

        rectangleButton.setTitle(nil, for: UIControl.State())
        rectangleButton.setBackgroundImages { selected, highlighted in
            return StyleKit.imageOfRectangleButton(
                lineWidth: lineWidth,
                selected: selected,
                highlighted: highlighted
            )
        }

        multiStarButton.setTitle(nil, for: UIControl.State())
        multiStarButton.setBackgroundImages { selected, highlighted in
            return StyleKit.imageOfMultiStarButton(
                lineWidth: lineWidth,
                selected: selected,
                highlighted: highlighted
            )
        }

        starButton.setTitle(nil, for: UIControl.State())
        starButton.setBackgroundImages { selected, highlighted in
            return StyleKit.imageOfStarButton(
                lineWidth: lineWidth,
                selected: selected,
                highlighted: highlighted
            )
        }
    }
}

// todo: move to view model
fileprivate extension EditStickerViewController {
    var imageSize: CGSize {
        return imageView.image?.size ?? .zero
    }

    var visibleRect: CGRect {
        return scrollView.convertBounds(to: imageView)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
