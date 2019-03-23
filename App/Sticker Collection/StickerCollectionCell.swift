//
//  StickerCollectionCell.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 08/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import Log
import RxCocoa
import RxSwift
import UIKit

class StickerCollectionCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var placeholderView: AppIconView!

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
        super.prepareForReuse()
        viewModel = nil
        imageView.image = nil
        placeholderView.isHidden = true
    }
}
