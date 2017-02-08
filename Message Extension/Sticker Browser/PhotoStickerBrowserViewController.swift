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
        self.view.tintColor = Appearance.tintColor
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

        viewModel!.sectionItems
            .map { items in
                [StickerSection(header: "Stickers", stickers: items)]
            }
            .bindTo(collectionView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)

        collectionView.rx
            .setDelegate(self)
            .addDisposableTo(disposeBag)

        collectionView.rx
            .modelSelected(StickerSectionItem.self)
            .filter { $0 == .OpenAppItem }
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel?.openApp()
            })
            .addDisposableTo(disposeBag)
    }
}

extension PhotoStickerBrowserViewController {
    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> PhotoStickerBrowserViewController {
        let viewController = storyboard.viewController(withID: .PhotoStickerBrowserViewController) as! PhotoStickerBrowserViewController
        return viewController
    }
}

// MARK: Skinning
extension PhotoStickerBrowserViewController {

    func skinTableViewDataSource(_ dataSource: RxCollectionViewSectionedReloadDataSource<StickerSection>) {
        dataSource.configureCell = { dataSource, collectionView, indexPath, _ in
            switch dataSource[indexPath] {
            case .OpenAppItem:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellReuseIdentifier.AddMoreCell.rawValue, for: indexPath)
                return cell
            case .StickerItem(sticker: let sticker):
                let cell: StickerBrowserCell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellReuseIdentifier.StickerBrowserCell.rawValue, for: indexPath) as! StickerBrowserCell
                cell.stickerView.sticker = MSSticker.load(sticker)
                return cell
            }
        }
    }
}

extension PhotoStickerBrowserViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
