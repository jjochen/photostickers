//
//  PhotosStickerBrowserViewController.swift
//  Photo Stickers
//
//  Created by Jochen Pfeiffer on 25/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import UIKit
import Messages
import Log
import RxSwift
import RxCocoa
import RxDataSources

class PhotoStickerBrowserViewController: UIViewController {

    var viewModel: PhotoStickerBrowserViewModel?
    fileprivate let disposeBag = DisposeBag()

    // MARK: Outlets / Actions

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }

    // MARK: - Bindings

    fileprivate func setupBindings() {
        guard let _ = viewModel else {
            Logger.shared.error("View Model not set!")
            return
        }

        let dataSource = RxCollectionViewSectionedReloadDataSource<StickerSection>()
        skinTableViewDataSource(dataSource)

        viewModel?.sectionItems
            .map { items in
                [StickerSection(header: "Stickers", stickers: items)]
            }
            .bindTo(collectionView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
    }

    func skinTableViewDataSource(_ dataSource: RxCollectionViewSectionedReloadDataSource<StickerSection>) {
        dataSource.configureCell = { dataSource, collectionView, indexPath, _ in
            switch dataSource[indexPath] {
            case .OpenAppItem:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellReuseIdentifier.AddMoreCell.rawValue, for: indexPath)

                return cell
            case .StickerItem(sticker: let sticker):
                let cell: StickerCell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellReuseIdentifier.StickerCell.rawValue, for: indexPath) as! StickerCell
                cell.stickerView.sticker = sticker.loadSticker()

                return cell
            }
        }

        //        dataSource.titleForHeaderInSection = { dataSource, index in
        //            let section = dataSource[index]
        //
        //            return section.title
        //        }
    }
}
