//
//  StickerCell.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 31/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import Log
import Messages
import UIKit

class StickerBrowserCell: UICollectionViewCell {
    @IBOutlet var stickerView: MSStickerView!
    @IBOutlet var placeholderView: AppIconView!

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
        placeholderView.isHidden = viewModel.placeholderHidden
    }

    override func prepareForReuse() {
        viewModel = nil
        stickerView.sticker = nil
        placeholderView.isHidden = true
    }
}
