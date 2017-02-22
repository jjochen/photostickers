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

    var viewModel: StickerCollectionViewModel?

    fileprivate let disposeBag = DisposeBag()

    @IBOutlet weak var stickerCollectionView: UICollectionView!
    @IBOutlet weak var addButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBindings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setupBindings() {
        guard let viewModel = self.viewModel else {
            Logger.shared.error("View Model not set!")
            return
        }

        self.addButtonItem.rx.tap
            .bindTo(viewModel.addButtonItemDidTap)
            .disposed(by: self.disposeBag)

        viewModel.presentImagePicker
            .flatMapLatest { [weak self] sourceType in
                return UIImagePickerController.rx.createWithParent(self) { picker in
                    picker.sourceType = sourceType
                    picker.allowsEditing = false
                }
                .flatMap {
                    $0.rx.didFinishPickingMediaWithInfo
                }
                .take(1)
            }
            .map { info in
                return info[UIImagePickerControllerOriginalImage] as? UIImage
            }
            .bindTo(viewModel.imagePicked)
            .disposed(by: self.disposeBag)

        self.viewModel!.stickerCellModels
            .bindTo(self.stickerCollectionView.rx.items(cellIdentifier: CollectionViewCellReuseIdentifier.StickerCollectionCell.rawValue)) { index, model, cell in
                guard let stickerCell = cell as? StickerCollectionCell else {
                    return
                }
                stickerCell.configure(model)
            }
            .disposed(by: disposeBag)

        self.stickerCollectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        self.stickerCollectionView.rx
            .modelSelected(StickerCollectionCellModel.self)
            .subscribe(onNext: { _ in
                Logger.shared.info("Sticker selected")
            })
            .disposed(by: disposeBag)
    }
}

extension StickerCollectionViewController {
    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> StickerCollectionViewController {
        let viewController = storyboard.viewController(withID: .StickerCollectionViewController) as! StickerCollectionViewController
        return viewController
    }
}

extension StickerCollectionViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
