//
//  StickerCollectionCell.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 08/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import UIKit
import Messages

class StickerCollectionCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    var viewModel: StickerCollectionCellModelType? {
        didSet {
            configure()
        }
    }

    func configure() {
        imageView.image = viewModel?.sticker.renderedSticker
    }

    override func prepareForReuse() {
        viewModel = nil
        imageView.image = nil
    }
}
