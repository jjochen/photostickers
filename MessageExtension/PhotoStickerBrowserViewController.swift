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

        //        let dataSource = RxCollectionViewSectionedReloadDataSource<>()
        //
        //        skinTableViewDataSource(dataSource)

        viewModel?.stickers
            .bindTo(collectionView.rx.items(cellIdentifier: CollectionViewCellReuseIdentifier.StickerCell.rawValue, cellType: StickerCell.self)) { row, sticker, cell in
                cell.stickerView.sticker = sticker.loadSticker()
            }
            .addDisposableTo(disposeBag)
    }

    //    func skinTableViewDataSource(_ dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel>) {
    //        dataSource.configureCell = { (dataSource, table, idxPath, _) in
    //            switch dataSource[idxPath] {
    //            case let .ImageSectionItem(image, title):
    //                let cell: ImageTitleTableViewCell = table.dequeueReusableCell(forIndexPath: idxPath)
    //                cell.titleLabel.text = title
    //                cell.cellImageView.image = image
    //
    //                return cell
    //            case let .StepperSectionItem(title):
    //                let cell: TitleSteperTableViewCell = table.dequeueReusableCell(forIndexPath: idxPath)
    //                cell.titleLabel.text = title
    //
    //                return cell
    //            case let .ToggleableSectionItem(title, enabled):
    //                let cell: TitleSwitchTableViewCell = table.dequeueReusableCell(forIndexPath: idxPath)
    //                cell.switchControl.isOn = enabled
    //                cell.titleLabel.text = title
    //
    //                return cell
    //            }
    //        }
    //
    //        dataSource.titleForHeaderInSection = { dataSource, index in
    //            let section = dataSource[index]
    //
    //            return section.title
    //        }
    //    }
}
