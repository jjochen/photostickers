//
//  StickerBrowserButtonView.swift
//  MessageExtension
//
//  Created by Jochen on 17.03.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import UIKit

class StickerBrowserButtonView: UICollectionReusableView {
    // Outlets
    @IBOutlet var editButton: UIButton!
    @IBOutlet var addButton: UIButton!

    var viewModel: StickerBrowserCellViewModelType? {
        didSet {
            configure()
        }
    }

    func configure() {
        guard let viewModel = viewModel else {
            return
        }
    }

    override func prepareForReuse() {
        viewModel = nil
    }
}
