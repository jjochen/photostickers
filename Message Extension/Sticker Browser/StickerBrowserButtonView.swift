//
//  StickerBrowserButtonView.swift
//  MessageExtension
//
//  Created by Jochen on 17.03.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class StickerBrowserButtonView: UICollectionReusableView {
    // Outlets
    @IBOutlet var editButton: UIButton!

    fileprivate var disposeBag: DisposeBag?

    var viewModel: StickerBrowserButtonViewModelType? {
        didSet {
            configure()
        }
    }

    func configure() {
        guard let viewModel = viewModel, let disposeBag = disposeBag else {
            return
        }

        editButton.rx.tap
            .bind(to: viewModel.editButtonDidTap)
            .disposed(by: disposeBag)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
        disposeBag = DisposeBag()
    }
}
