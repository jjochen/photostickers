//
//  StickerTests.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 30/01/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import XCTest
@testable import PhotoStickers

class StickerTests: XCTestCase {
}

extension StickerTests {
    func testStickerCreation() {
        let sticker = Sticker()
        sticker.uuid = "1234-5678"
        sticker.originalImageFilePath = "some/path"
        sticker.localizedDescription = "awesome sticker"
        sticker.sortOrder = 42

        XCTAssertNotNil(sticker)
    }

    func testStickerEquality() {
        let sticker1 = Sticker()
        let sticker2 = Sticker()
        XCTAssertTrue(sticker1 == sticker2)

        let uuid = "uuid"
        sticker1.uuid = uuid
        XCTAssertFalse(sticker1 == sticker2)
        sticker2.uuid = uuid
        XCTAssertTrue(sticker1 == sticker2)

        let path = "path"
        sticker1.originalImageFilePath = path
        XCTAssertTrue(sticker1 == sticker2)
    }
}
