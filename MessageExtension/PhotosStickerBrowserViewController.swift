//
//  PhotosStickerBrowserViewController.swift
//  Photo Stickers
//
//  Created by Jochen Pfeiffer on 25/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import UIKit
import Messages

class PhotosStickerBrowserViewController: MSStickerBrowserViewController
{
    var stickers = [MSSticker]()
    
    public func loadStickers() {
        loadSticker(asset: "sticker.png", localizedDescription: "Pizza")
        stickerBrowserView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStickers()
    }
    
    fileprivate func loadSticker(asset: String, localizedDescription: String) {
        
        guard let stickerURL = AppGroup.documentsURL?.appendingPathComponent(asset) else {
            return
        }
        let sticker: MSSticker
        do {
            try sticker = MSSticker(contentsOfFileURL: stickerURL, localizedDescription: localizedDescription)
            stickers.append(sticker)
        } catch {
            print(error)
            return
        }
    }
    
    override func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
        return stickers.count
    }
    
    override func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
        return stickers[index]
    }
    
    
    
    
}
