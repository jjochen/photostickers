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

    func configure(_ viewModel: StickerCollectionCellModel) {
        imageView.image = viewModel.image
    }
}
