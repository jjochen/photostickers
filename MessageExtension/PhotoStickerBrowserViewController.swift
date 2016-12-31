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
            Logger().error("View Model not set!")
            return
        }

        viewModel?.stickers
            .drive(collectionView.rx.items(cellIdentifier: CollectionViewCellReuseIdentifier.StickerCell.rawValue, cellType: StickerCell.self)) { _, sticker, cell in
                cell.stickerView.sticker = sticker
            }
            .addDisposableTo(disposeBag)

        //        _ = refreshBarButtonItem.rx.tap.bindTo(viewModel!.refreshTaps)
        //
        //        viewModel!.availableBridges
        //            .drive(tableView.rx.items(cellIdentifier: TableViewCellreuseIdentifier.BridgeCell.rawValue, cellType: UITableViewCell.self)) { (_, bridgeInfo, cell) in
        //                //                cell.viewModel = self.viewModel
        //                cell.textLabel?.text = bridgeInfo.friendlyName
        //                cell.detailTextLabel?.text = bridgeInfo.ip
        //            }
        //            .addDisposableTo(disposeBag)
        //
        //        tableView
        //            .rx.modelSelected(HueBridge.self)
        //            .subscribe { hueBridge in
        //                print("\(hueBridge)")
        //            }
        //            .addDisposableTo(disposeBag)
        //
        //        viewModel!.loading
        //            .map({ loading in
        //                return !loading
        //            })
        //            .drive(self.refreshBarButtonItem.rx.isEnabled)
        //            .addDisposableTo(disposeBag)
        //
        //        viewModel!.loading
        //            .drive(SVProgressHUD.rx_animating)
        //            .addDisposableTo(disposeBag)
    }

    //    fileprivate func loadSticker(asset: String, localizedDescription: String) {
    //
    //        guard let stickerURL = AppGroup.documentsURL?.appendingPathComponent(asset) else {
    //            return
    //        }
    //        let sticker: MSSticker
    //        do {
    //            try sticker = MSSticker(contentsOfFileURL: stickerURL, localizedDescription: localizedDescription)
    //            stickers.append(sticker)
    //        } catch {
    //            print(error)
    //            return
    //        }
    //    }
}
