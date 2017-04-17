//
//  ImageRenderServiceMock.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 17.04.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit
import RxSwift
@testable import PhotoStickers

class StickerRenderServiceMock: StickerRenderServiceType {
    fileprivate var bundle: Bundle {
        return Bundle(for: type(of: self))
    }

    func render(_: StickerInfo) -> Observable<UIImage?> {
        let image = UIImage(named: "sticker.png", in: bundle, compatibleWith: nil)
        return Observable.just(image)
    }
}
