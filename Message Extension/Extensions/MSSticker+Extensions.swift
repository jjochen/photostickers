//
//  MSSticker+Extensions.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 31/01/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import Messages
import Log

extension MSSticker {

    static func load(_ sticker: Sticker?) -> MSSticker? {
        guard let stickerURL = sticker?.renderedStickerURL as URL! else {
            return nil
        }
        guard let localizedDescription = sticker?.localizedDescription as String! else {
            return nil
        }

        var msSticker: MSSticker
        do {
            try msSticker = MSSticker(contentsOfFileURL: stickerURL, localizedDescription: localizedDescription)
        } catch {
            Logger.shared.error(error)
            return nil
        }
        return msSticker
    }
}
