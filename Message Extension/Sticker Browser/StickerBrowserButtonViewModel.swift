//
//  StickerBrowserButtonViewModel.swift
//  PhotoStickers
//
//  Created by Jochen on 23.03.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import Log
import RxCocoa
import RxSwift

protocol StickerBrowserButtonViewModelType: class {
    var editButtonDidTap: PublishSubject<Void> { get }
}

class StickerBrowserButtonViewModel: BaseViewModel, StickerBrowserButtonViewModelType {
    let editButtonDidTap: PublishSubject<Void>

    init(editButtonDidTap: PublishSubject<Void>) {
        self.editButtonDidTap = editButtonDidTap
        super.init()
    }
}
