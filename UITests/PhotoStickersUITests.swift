//
//  PhotoStickersUITests.swift
//  PhotoStickersUITests
//
//  Created by Jochen Pfeiffer on 28/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import XCTest

class PhotoStickersUITests: XCTestCase {

    fileprivate var app: XCUIApplication?

    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        app = XCUIApplication()
        app?.launchArguments += ["-RunningUITests", "true"]
        setupSnapshot(app!)
        app?.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func testSnapshots() {
        guard let app = self.app else {
            fatalError()
        }

        snapshot("Sticker Collection")

        app.navigationBars["StickerCollectionNavigtionBar"].buttons["AddButtonItem"].tap()

        snapshot("Edit Sticker Empty")

        app.sheets.buttons["ImageSourceAlertButtonCancel"].tap()
        app.buttons["StarButton"].tap()
        app.navigationBars["EditStickerNavigationBar"].buttons["CancelButtonItem"].tap()

        //        app.collectionViews["StickerCollectionView"].cells["StickerCollectionCell"].children(matching: .other).element.tap()
        //        app.buttons["RectangleButton"].tap()
        //        app.navigationBars["EditStickerNavigationBar"].buttons["SaveButtonItem"].tap()
    }
}
