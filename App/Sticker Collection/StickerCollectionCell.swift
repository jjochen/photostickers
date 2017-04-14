//
//  StickerCollectionCell.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 08/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Log

class StickerCollectionCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var placeholderView: AppIconView!

    var viewModel: StickerCollectionCellModelType? {
        didSet {
            configure()
        }
    }

    func configure() {
        guard let viewModel = viewModel else {
            return
        }

        imageView.image = viewModel.image
        placeholderView.isHidden = viewModel.placeholderHidden
    }

    override func prepareForReuse() {
        viewModel = nil
        imageView.image = nil
        placeholderView.isHidden = true
    }
}
