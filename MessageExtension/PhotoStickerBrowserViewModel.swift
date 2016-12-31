//
//  PhotoStickerBrowserViewModel.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 30/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import Messages
import RxCocoa
import RxSwift

class PhotoStickerBrowserViewModel: ViewModel {
    // MARK: - Input

    // MARK: - Output

    internal let stickers: Driver<[MSSticker]>

    override init() {
        let testSticker = PhotoStickerBrowserViewModel.loadSticker(asset: "sticker.png", localizedDescription: "Pizza")

        let listOfStickers: [MSSticker] = [testSticker!]

        self.stickers = Driver<[MSSticker]>.just(listOfStickers)
    }

    fileprivate static func loadSticker(asset: String, localizedDescription: String) -> MSSticker? {

        guard let stickerURL = AppGroup.documentsURL?.appendingPathComponent(asset) else {
            return nil
        }
        let sticker: MSSticker
        do {
            try sticker = MSSticker(contentsOfFileURL: stickerURL, localizedDescription: localizedDescription)

        } catch {
            print(error)
            return nil
        }
        return sticker
    }
}
