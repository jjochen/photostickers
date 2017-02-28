//
//  ViewController.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 28/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Log
import RxDataSources

class StickerCollectionViewController: UIViewController {

    var viewModel: StickerCollectionViewModelType?

    fileprivate let disposeBag = DisposeBag()

    @IBOutlet weak var stickerCollectionView: UICollectionView!
    @IBOutlet weak var addButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBindings()
    }

    func setupBindings() {
        guard let viewModel = self.viewModel else {
            Logger.shared.error("View Model not set!")
            return
        }

        viewModel.stickerCellModels
            .bindTo(self.stickerCollectionView.rx.items(cellIdentifier: CollectionViewCellReuseIdentifier.StickerCollectionCell.rawValue)) { index, model, cell in
                guard let stickerCell = cell as? StickerCollectionCell else {
                    return
                }
                stickerCell.viewModel = model
            }
            .disposed(by: disposeBag)

        self.stickerCollectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        //        self.stickerCollectionView.rx
        //            .modelSelected(StickerCollectionCellModel.self)
        //            .subscribe(onNext: { _ in
        //                Logger.shared.info("Sticker selected")
        //            })
        //            .disposed(by: disposeBag)
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

        func getEditStickerViewController(from segue: UIStoryboardSegue) -> EditStickerViewController! {
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
            guard let viewController = getEditStickerViewController(from: segue) else {
                return
            }
            viewController.viewModel = viewModel.editStickerViewModel(for: sticker)

        } else if segue == .AddStickerSeque {
            guard let viewController = getEditStickerViewController(from: segue) else {
                return
            }
            viewController.viewModel = viewModel.addStickerViewModel()
        }
    }
}

extension StickerCollectionViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
