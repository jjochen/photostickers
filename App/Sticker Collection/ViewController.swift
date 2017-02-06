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
import RealmSwift
import Log

class ViewController: UIViewController {

    fileprivate let disposeBag = DisposeBag()

    @IBOutlet weak var addButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBindings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setupBindings() {
        addButton.rx.tap
            .flatMapLatest { [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self) { picker in
                    picker.sourceType = .photoLibrary
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
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { image in
                self.storeSticker(with: image)
            })
            .addDisposableTo(disposeBag)
    }

    func storeSticker(with image: UIImage?) {

        guard let originalImage = image else {
            return
        }
        let uuid = UUID().uuidString

        let sticker = Sticker()
        sticker.uuid = uuid
        sticker.originalImage = originalImage
        sticker.localizedDescription = "Sticker"
        sticker.sortOrder = 1
        sticker.cropBounds = CGRect(x: 0, y: 0, width: 600, height: 600)

        StickerRenderer.render(sticker)

        Realm.configureForAppGroup()
        let realm = try! Realm()
        try! realm.write {
            realm.add(sticker)
        }
    }
}
