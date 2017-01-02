//
//  Sticker+CoreDataClass.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 01/01/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import Messages
import Log

struct Sticker {

    var uuid: String
    var stickerPath: String?
    var stickerDescription: String?
    var sortOrder: Int
}

extension Sticker {
    public func localizedDescription() -> String! {
        guard let localizedDescription = self.stickerDescription else {
            return "Sticker"
        }
        return localizedDescription
    }

    public func stickerURL() -> URL? {
        guard let filePath = stickerPath else {
            return nil
        }
        let stickerURL = URL(string: filePath)
        return stickerURL
    }
}

extension Sticker {
    public func loadSticker() -> MSSticker? {
        let stickerURL: URL? = self.stickerURL()
        let localizedDescription: String! = self.localizedDescription()
        guard stickerURL != nil else {
            return nil
        }
        let sticker: MSSticker
        do {
            try sticker = MSSticker(contentsOfFileURL: stickerURL!, localizedDescription: localizedDescription)
        } catch {
            Logger.shared.error(error)
            return nil
        }
        return sticker
    }
}
