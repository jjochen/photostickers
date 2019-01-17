//
//  ViewController.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 28/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Log
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class StickerCollectionViewController: UIViewController {
    var viewModel: StickerCollectionViewModelType?

    fileprivate let disposeBag = DisposeBag()

    @IBOutlet var stickerCollectionView: UICollectionView!
    @IBOutlet var addButtonItem: UIBarButtonItem!
    @IBOutlet var arrowView: ArrowView!
    @IBOutlet var arrowOffsetLayoutConstraint: NSLayoutConstraint!

    fileprivate var arrowTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupArrow()
        setupBindings()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stickerCollectionView.collectionViewLayout.invalidateLayout()
    }

    func setupBindings() {
        guard let viewModel = self.viewModel else {
            Logger.shared.error("View Model not set!")
            return
        }

        viewModel.stickerCellModels
            .drive(stickerCollectionView.rx.items(cellIdentifier: CollectionViewCellReuseIdentifier.StickerCollectionCell.rawValue)) { _, model, cell in
                guard let stickerCell = cell as? StickerCollectionCell else {
                    return
                }
                stickerCell.viewModel = model
            }
            .disposed(by: disposeBag)

        stickerCollectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        viewModel.arrowHidden
            .drive(onNext: { [weak self] hidden in
                guard let `self` = self else { return }
                if hidden {
                    self.hideArrow()
                } else {
                    self.showArrow()
                }
            })
            .disposed(by: disposeBag)

        viewModel.presentFirstStickerAlert
            .drive(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.presentFirstStickerAlert()
            })
            .disposed(by: disposeBag)
    }
}

fileprivate extension StickerCollectionViewController {
    func presentFirstStickerAlert() {
        guard presentedViewController == nil else {
            DispatchQueue.main.async {
                self.presentFirstStickerAlert()
            }
            return
        }
        let alertController = UIAlertController(
            title: "FirstStickerAlertTitle".localized,
            message: "FirstStickerAlertMessage".localized,
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: "OK".localized,
                                     style: .default,
                                     handler: nil)
        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
    }
}

fileprivate extension StickerCollectionViewController {
    func setupArrow() {
        arrowView.alpha = 0
        arrowView.isHidden = true
        arrowView.backgroundColor = UIColor.clear
        arrowOffsetLayoutConstraint.constant = minArrowPosition
    }

    func showArrow() {
        arrowView.isHidden = false

        if arrowTimer != nil, arrowTimer!.isValid {
            return
        }

        arrowTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { _ in
            self.animateArrow()
        })
        arrowTimer?.tolerance = 0.5
    }

    func hideArrow() {
        if arrowView.isHidden {
            return
        }

        arrowView.isHidden = true
        arrowTimer?.invalidate()
        arrowTimer = nil
    }

    var minArrowPosition: CGFloat {
        return 6
    }

    var maxArrowPosition: CGFloat {
        return 16
    }

    func animateArrow() {
        if arrowView.isHidden {
            return
        }

        if arrowView.alpha == 0 {
            animateArrowAlpha()
        } else {
            bounceArrow()
        }
    }

    func animateArrowAlpha() {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: {
                           self.arrowView.alpha = 1
                       },
                       completion: nil)
    }

    func bounceArrow() {
        let layoutAnimation = {
            self.view.layoutIfNeeded()
        }

        arrowOffsetLayoutConstraint.constant = maxArrowPosition
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: layoutAnimation,
                       completion: { _ in
                           self.arrowOffsetLayoutConstraint.constant = self.minArrowPosition
                           UIView.animate(withDuration: 0.5,
                                          delay: 0,
                                          usingSpringWithDamping: 0.2,
                                          initialSpringVelocity: 0.0,
                                          options: .curveEaseIn,
                                          animations: layoutAnimation,
                                          completion: nil)
        })
    }
}

extension StickerCollectionViewController {
    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> StickerCollectionViewController {
        let viewController = storyboard.viewController(withID: .StickerCollectionViewController) as! StickerCollectionViewController
        return viewController
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewModel = self.viewModel else {
            Logger.shared.error("View Model not set!")
            return
        }

        func getEditStickerViewController(from segue: UIStoryboardSegue) -> EditStickerViewController {
            let navigationController = segue.destination as! UINavigationController
            let viewController = navigationController.topViewController as! EditStickerViewController
            return viewController
        }

        if segue == .EditStickerSegue {
            let cell = sender as! StickerCollectionCell
            guard let sticker = cell.viewModel?.sticker else {
                Logger.shared.error("Cell has no sticker!")
                return
            }
            let viewController = getEditStickerViewController(from: segue)
            viewController.viewModel = viewModel.editStickerViewModel(for: sticker)

        } else if segue == .AddStickerSeque {
            let viewController = getEditStickerViewController(from: segue)
            viewController.viewModel = viewModel.addStickerViewModel()
        }
    }
}

extension StickerCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension StickerCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return StickerFlowLayout.itemSize(in: collectionView.bounds)
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        return StickerFlowLayout.sectionInsets(in: collectionView.bounds)
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return StickerFlowLayout.minimumLineSpacing(in: collectionView.bounds)
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return StickerFlowLayout.minimumLineSpacing(in: collectionView.bounds)
    }
}
