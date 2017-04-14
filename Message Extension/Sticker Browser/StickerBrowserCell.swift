//
//  StickerCell.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 31/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import UIKit
import Messages
import Log

class StickerBrowserCell: UICollectionViewCell {

    @IBOutlet weak var stickerView: MSStickerView!
    @IBOutlet weak var placeholderView: AppIconView!

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
