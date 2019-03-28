//
//  PhotosStickerBrowserViewController.swift
//  Photo Stickers
//
//  Created by Jochen Pfeiffer on 25/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import Log
import Messages
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

/* TODO:
 * check https://github.com/sergdort/CleanArchitectureRxSwift
 * show toolbar with edit/done button only in expanded mode
 * only in edit mode: edit, sort, delete sticker
 */

class PhotoStickerBrowserViewController: UIViewController {
    var viewModel: PhotoStickerBrowserViewModelType?
    fileprivate let disposeBag = DisposeBag()

    // MARK: Outlets / Actions

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var editBarButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Bindings

    fileprivate func setupBindings() {
        guard let viewModel = self.viewModel else {
            Logger.shared.error("View Model not set!")
            return
        }

//        rx.willTransition
//            .bind(to: viewModel.currentPresentationStyle)
//            .disposed(by: disposeBag)

        editBarButtonItem.rx
            .tap
            .bind(to: viewModel.editButtonDidTap)
            .disposed(by: disposeBag)

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
        dataSource.configureSupplementaryView = { _, collectionView, kind, indexPath in
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionReusableViewReuseIdentifier.StickerBrowserButtonView.rawValue, for: indexPath) as! StickerBrowserButtonView
            view.viewModel = viewModel.stickerBrowserButtonViewModel()
            return view
        }

        viewModel.sectionItems
            .map { items in
                [StickerSection(stickers: items)]
            }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

//        viewModel.requestPresentationStyle
//            .drive(rx.requestPresentationStyle)
//            .disposed(by: disposeBag)

        viewModel.navigationBarHidden
            .drive(onNext: { hidden in
                self.navigationController?.setNavigationBarHidden(hidden, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension PhotoStickerBrowserViewController {
    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> PhotoStickerBrowserViewController {
        let viewController = storyboard.viewController(withID: .PhotoStickerBrowserViewController) as! PhotoStickerBrowserViewController
        return viewController
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        func getEditStickerViewController(from segue: UIStoryboardSegue) -> EditStickerViewController {
            let navigationController = segue.destination as! UINavigationController
            let viewController = navigationController.topViewController as! EditStickerViewController
            return viewController
        }

        guard let viewModel = self.viewModel else {
            Logger.shared.error("View Model not set!")
            return
        }

        if segue == .AddStickerSegue {
            let viewController = getEditStickerViewController(from: segue)
            viewController.viewModel = viewModel.addStickerViewModel()
        } else if segue == .EditStickerSegue {
            let cell = sender as! StickerBrowserCell
            guard let sticker = cell.viewModel?.sticker else {
                Logger.shared.error("Cell has no sticker!")
                return
            }
            let viewController = getEditStickerViewController(from: segue)
            viewController.viewModel = viewModel.editStickerViewModel(for: sticker)
        }
    }
}

extension PhotoStickerBrowserViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension PhotoStickerBrowserViewController: UICollectionViewDelegateFlowLayout {
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
