//
//  PhotosStickerBrowserViewController.swift
//  Photo Stickers
//
//  Created by Jochen Pfeiffer on 25/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import Messages
import Reusable
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

/* TODO:
 * check https://github.com/sergdort/CleanArchitectureRxSwift
 * show toolbar with edit/done button only in expanded mode
 * only in edit mode: edit, sort, delete sticker
 */

enum StickerBrowserActionButtonType {
    case edit
    case done
}

class StickerBrowserViewController: UIViewController, StoryboardBased, ViewModelBased {
    var viewModel: StickerBrowserViewModel!
    fileprivate let disposeBag = DisposeBag()

    @IBOutlet var collectionView: UICollectionView!

    let editBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
    let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)

    var requestPresentationStyle: PublishSubject<MSMessagesAppPresentationStyle>?
    var currentPresentationStyle: Driver<MSMessagesAppPresentationStyle>?

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Bindings

    fileprivate func bindViewModel() {
        guard let viewModel = self.viewModel else {
            fatalError("View Model not set!")
        }
        guard let currentPresentationStyle = self.currentPresentationStyle else {
            fatalError("Current Presentation Style not set up!")
        }
        guard let requestPresentationStyle = self.requestPresentationStyle else {
            fatalError("Request Presentation Style not set up!")
        }

        let dataSource = RxCollectionViewSectionedReloadDataSource<StickerSection>(
            configureCell: { _, collectionView, indexPath, item in
                switch item {
                case .openAppItem:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellReuseIdentifier.AddMoreCell.rawValue, for: indexPath)
                    return cell
                case let .stickerItem(viewModel: cellViewModel):
                    let cell: StickerBrowserCell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellReuseIdentifier.StickerBrowserCell.rawValue, for: indexPath) as! StickerBrowserCell
                    cell.viewModel = cellViewModel
                    return cell
                }
            }
        )

        let editTrigger = editBarButtonItem.rx.tap.map { StickerBrowserActionButtonType.edit }
        let doneTrigger = doneBarButtonItem.rx.tap.map { StickerBrowserActionButtonType.done }
        let actionButtonTrigger = Observable.of(editTrigger, doneTrigger)
            .merge()
            .asDriver(onErrorDriveWith: Driver.empty())

        let indexPathSelected = collectionView.rx.itemSelected.asDriver()

        let input = StickerBrowserViewModel.Input(actionButtonDidTap: actionButtonTrigger,
                                                  currentPresentationStyle: currentPresentationStyle,
                                                  indexPathSelected: indexPathSelected)

        let output = viewModel.transform(input: input)

        output.sectionItems
            .map { items in
                [StickerSection(stickers: items)]
            }
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        output.openStickerItem
            .drive()
            .disposed(by: disposeBag)

        collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        output.requestPresentationStyle
            .drive(requestPresentationStyle)
            .disposed(by: disposeBag)

        output.navigationBarHidden
            .drive(onNext: { hidden in
                self.navigationController?.setNavigationBarHidden(hidden, animated: true)
            })
            .disposed(by: disposeBag)

        output.actionButtonType
            .drive(onNext: { type in
                self.showActionButton(forType: type)
            })
            .disposed(by: disposeBag)
    }
}

extension StickerBrowserViewController {
    func showActionButton(forType type: StickerBrowserActionButtonType) {
        switch type {
        case .edit:
            navigationItem.rightBarButtonItem = editBarButtonItem
        case .done:
            navigationItem.rightBarButtonItem = doneBarButtonItem
        }
    }
}

extension StickerBrowserViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension StickerBrowserViewController: UICollectionViewDelegateFlowLayout {
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
