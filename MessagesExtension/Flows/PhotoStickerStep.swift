//
//  PhotoStickerStep.swift
//  MessageExtension
//
//  Created by Jochen on 02.04.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import RxFlow

enum PhotoStickerStep: Step {
    case stickerBrowserIsRequired

    case addStickerIsPicked
    case stickerIsPicked(sticker: Sticker)

    case editStickerComplete
}
