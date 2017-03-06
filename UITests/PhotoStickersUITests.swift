//
//  PhotoStickersUITests.swift
//  PhotoStickersUITests
//
//  Created by Jochen Pfeiffer on 28/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import XCTest

class PhotoStickersUITests: XCTestCase {

    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDown() {

        super.tearDown()
    }

    func NOtestExample() {

        let app = XCUIApplication()

        snapshot("Sticker Collection")

        app.navigationBars["Photo Stickers"].buttons["Add"].tap()
        app.collectionViews["PhotosGridView"].cells["Photo, Landscape, March 13, 2011, 1:17 AM"].tap()

        snapshot("Edit Sticker")

        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element
        element.swipeRight()
        element.swipeRight()
        element.swipeLeft()

        let stickerNavigationBar = app.navigationBars["Sticker"]
        stickerNavigationBar.buttons["Save"].tap()
        app.collectionViews.images["/Users/jochen/Library/Developer/CoreSimulator/Devices/904D0533-331B-4B67-86DD-C92C219FDB2A/data/Containers/Shared/AppGroup/D976DD70-7D49-4FF3-A9D2-70BF05143BC0/images/stickers/D0B455F6-CA77-4CD7-BB9C-A347606965C6.png"].tap()
        stickerNavigationBar.buttons["Cancel"].tap()
    }
}
