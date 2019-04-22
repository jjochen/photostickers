//
//  AddCell.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 09.04.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit

class AddStickerCell: UICollectionViewCell {
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var imageView: UIImageView!

    override func awakeFromNib() {
        // use dependency injection for render service
        let renderService = StickerRenderService()
        let mask = Mask.circle
        let backgroundPixelNormal = StyleKit.plusBackgroundColorNormal.image()
        let backgroundPixelHighlighted = StyleKit.plusBackgroundColorHighlighted.image()

        backgroundImageView.image = renderService.render(backgroundPixelNormal, mask: mask)
        backgroundImageView.highlightedImage = renderService.render(backgroundPixelHighlighted, mask: mask)

        imageView.image = StyleKit.imageOfPlusIcon(highlighted: false)
        imageView.highlightedImage = StyleKit.imageOfPlusIcon(highlighted: true)
    }
}
