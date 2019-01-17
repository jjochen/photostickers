//
//  ImageRenderServiceMock.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 17.04.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

@testable import PhotoStickers
import RxSwift
import UIKit

class StickerRenderServiceMock: StickerRenderServiceType {
    fileprivate var bundle: Bundle {
        return Bundle(for: type(of: self))
    }

    func render(_: StickerInfo) -> Observable<UIImage?> {
        let image = UIImage(named: "sticker.png", in: bundle, compatibleWith: nil)
        return Observable.just(image)
    }
}
