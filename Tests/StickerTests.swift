//
//  StickerTests.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 30/01/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Quick
import Nimble
@testable
import PhotoStickers

class StickerTests: QuickSpec {
    override func spec() {

        it("is not nil") {
            let sticker = Sticker()
            expect(sticker).notTo(beNil())
        }

        it("is equal to ohter sticker when it has the same uuid") {
            let sticker1 = Sticker()
            let sticker2 = Sticker()

            expect(sticker1 == sticker2).to(beTrue())

            let uuid = "uuid"
            sticker1.uuid = uuid
            expect(sticker1 == sticker2).to(beFalse())
            sticker2.uuid = uuid
            expect(sticker1 == sticker2).to(beTrue())

            sticker1.cropBounds = CGRect(x: 1, y: 2, width: 3, height: 4)
            expect(sticker1 == sticker2).to(beTrue())
        }

        it("sets the correct bounds") {
            let bounds = CGRect(x: 11, y: 22, width: 33, height: 44)
            let sticker = Sticker()
            sticker.cropBounds = bounds

            expect(sticker.cropBoundsX) == Double(bounds.minX)
            expect(sticker.cropBoundsY) == Double(bounds.minY)
            expect(sticker.cropBoundsWidth) == Double(bounds.width)
            expect(sticker.cropBoundsHeight) == Double(bounds.height)
        }

        it("has a uuid on creation") {
            let sticker = Sticker.newSticker()
            expect(sticker.uuid).notTo(beNil())
        }
    }
}
