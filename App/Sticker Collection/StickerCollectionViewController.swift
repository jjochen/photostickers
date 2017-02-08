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

class StickerCollectionViewController: UIViewController {

    var viewModel: StickerCollectionViewModel?
    fileprivate let disposeBag = DisposeBag()

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBindings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setupBindings() {
        guard let _ = self.viewModel else {
            Logger.shared.error("View Model not set!")
            return
        }

        self.addButton.rx.tap
            .bindTo(self.viewModel!.addButtonItemDidTap)
            .addDisposableTo(self.disposeBag)

        self.viewModel!.presentImagePicker
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
            .bindTo(self.viewModel!.imagePicked)
            .addDisposableTo(self.disposeBag)
    }
}
