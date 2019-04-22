//
//  StickerCell.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 31/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import Messages
import RxCocoa
import RxSwift
import UIKit

class StickerBrowserCell: UICollectionViewCell, WiggleEffect {
    @IBOutlet var stickerView: MSStickerView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var placeholderView: AppIconView!

    fileprivate var disposeBag = DisposeBag()

    var viewModel: StickerBrowserCellViewModelType? {
        didSet {
            configure()
        }
    }

    func configure() {
        guard let viewModel = viewModel else {
            return
        }

        stickerView.sticker = viewModel.msSticker
        imageView.image = viewModel.image
        placeholderView.isHidden = viewModel.placeholderHidden

        viewModel.hideSticker
            .drive(stickerView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.hideImageView
            .drive(imageView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.wiggle
            .distinctUntilChanged()
            .drive(onNext: { [weak self] shouldWobble in
                if shouldWobble {
                    self?.startWiggle()
                } else {
                    self?.stopWiggle()
                }
            })
            .disposed(by: disposeBag)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
        disposeBag = DisposeBag()
        stickerView.sticker = nil
        placeholderView.isHidden = true
    }
}
