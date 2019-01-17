//
//  StickerRenderService+UITestSetup.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 10.04.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import Log
import RxSwift

extension StickerService {
    func setupUITests() {
        deleteAll() //todo: doesn't delete images

        let disposeBag = DisposeBag()
        let stickerInfo = StickerInfo()
        stickerInfo.originalImage.value = UIImage(named: "original.jpg")
        storeSticker(withInfo: stickerInfo).debug().subscribe {}.disposed(by: disposeBag)
    }
}
