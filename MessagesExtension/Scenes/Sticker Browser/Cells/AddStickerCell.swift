//
//  AddCell.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 09.04.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit

class AddStickerCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!

    override func awakeFromNib() {
        // todo: use StickerRenderService

        imageView.image = StyleKit.imageOfAddIcon(highlighted: false)
        imageView.highlightedImage = StyleKit.imageOfAddIcon(highlighted: true)
    }
}
