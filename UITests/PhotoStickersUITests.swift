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
        guard app != nil else {
            fatalError()
        }

        XCTAssert(stickerCollectionNavigtionBar.exists)
        XCTAssert(collectionView.exists)

        snapshot("1_Sticker_Collection")

        XCTAssert(addButtonItem.exists)

        addButtonItem.tap()

        XCTAssert(imageSourceAlertButtonPhotoLibrary.exists)
        XCTAssert(imageSourceAlertButtonCamera.exists)

        if isIPad() {
            appWindow.tap()
        } else {
            XCTAssert(imageSourceAlertButtonCancel.exists)
            imageSourceAlertButtonCancel.tap()
        }

        XCTAssert(circleButton.exists)
        XCTAssert(rectangleButton.exists)
        XCTAssert(multiStarButton.exists)
        XCTAssert(starButton.exists)
        XCTAssert(editStickerNavigationBar.exists)
        XCTAssert(editStickerToolbar.exists)
        XCTAssert(saveButtonItem.exists)
        XCTAssert(cancelButtonItem.exists)
        XCTAssert(deleteButtonItem.exists)
        XCTAssert(photoButtonItem.exists)

        cancelButtonItem.tap()

        XCTAssert(collectionView.exists)
        XCTAssert(firstStickerCell.exists)

        firstStickerCell.tap()
        rectangleButton.tap()

        snapshot("2_Edit_Sticker")

        saveButtonItem.tap()

        firstStickerCell.tap()
    }
}

// MARK: UI Elements
fileprivate extension PhotoStickersUITests {
    var appWindow: XCUIElement {
        return app!.children(matching: .window).element(boundBy: 0)
    }

    var stickerCollectionNavigtionBar: XCUIElement {
        return app!.navigationBars["StickerCollectionNavigtionBar"]
    }

    var addButtonItem: XCUIElement {
        return stickerCollectionNavigtionBar.buttons["AddButtonItem"]
    }

    var imageSourceAlertButtonPhotoLibrary: XCUIElement {
        return app!.sheets.buttons["ImageSourceAlertButtonPhotoLibrary"]
    }

    var imageSourceAlertButtonCamera: XCUIElement {
        return app!.sheets.buttons["ImageSourceAlertButtonCamera"]
    }

    var imageSourceAlertButtonCancel: XCUIElement {
        return app!.sheets.buttons["ImageSourceAlertButtonCancel"]
    }

    var circleButton: XCUIElement {
        return app!.buttons["CircleButton"]
    }

    var rectangleButton: XCUIElement {
        return app!.buttons["RectangleButton"]
    }

    var multiStarButton: XCUIElement {
        return app!.buttons["MultiStarButton"]
    }

    var starButton: XCUIElement {
        return app!.buttons["StarButton"]
    }

    var editStickerNavigationBar: XCUIElement {
        return app!.navigationBars["EditStickerNavigationBar"]
    }

    var editStickerToolbar: XCUIElement {
        return app!.toolbars["EditStickerToolbar"]
    }

    var saveButtonItem: XCUIElement {
        return editStickerNavigationBar.buttons["SaveButtonItem"]
    }

    var cancelButtonItem: XCUIElement {
        return editStickerNavigationBar.buttons["CancelButtonItem"]
    }

    var deleteButtonItem: XCUIElement {
        return editStickerToolbar.buttons["DeleteButtonItem"]
    }

    var photoButtonItem: XCUIElement {
        return editStickerToolbar.buttons["PhotoButtonItem"]
    }

    var collectionView: XCUIElement {
        return app!.collectionViews["StickerCollectionView"]
    }

    var stickerCells: XCUIElementQuery {
        return collectionView.cells.matching(identifier: "StickerCollectionCell")
    }

    var firstStickerCell: XCUIElement {
        return stickerCells.element(boundBy: 0)
    }
}

// MARK: Helper
fileprivate extension PhotoStickersUITests {
    func isIPad() -> Bool {
        return app!.windows.element(boundBy: 0).horizontalSizeClass == .regular && app!.windows.element(boundBy: 0).verticalSizeClass == .regular
    }
}
