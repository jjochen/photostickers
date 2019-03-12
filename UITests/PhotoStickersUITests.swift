//
//  PhotoStickersUITests.swift
//  PhotoStickersUITests
//
//  Created by Jochen Pfeiffer on 28/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import XCTest

class PhotoStickersUITests: XCTestCase {
    func testUI() {
        let app = XCUIApplication()

        app.launchArguments += ["-RunningUITests", "true"]
        setupSnapshot(app)
        app.launch()

        let stickerCollectionNavigtionBar = app.navigationBars["StickerCollectionNavigtionBar"]
        XCTAssert(stickerCollectionNavigtionBar.exists)

        let collectionView = app.collectionViews["StickerCollectionView"]
        XCTAssert(collectionView.exists)

        snapshot("1_Sticker_Collection")

        let addButtonItem = stickerCollectionNavigtionBar.buttons["AddButtonItem"]
        XCTAssert(addButtonItem.exists)

        addButtonItem.tap()

        let sheetsQuery = app.sheets

        let imageSourceAlertButtonPhotoLibrary = sheetsQuery.buttons["ImageSourceAlertButtonPhotoLibrary"]
        XCTAssert(imageSourceAlertButtonPhotoLibrary.exists)

        let imageSourceAlertButtonCamera = sheetsQuery.buttons["ImageSourceAlertButtonCamera"]
        XCTAssert(imageSourceAlertButtonCamera.exists)

        if isIPad() {
            let appWindow = app.children(matching: .window).element(boundBy: 0)
            appWindow.tap()
        } else {
            let imageSourceAlertButtonCancel = sheetsQuery.buttons["ImageSourceAlertButtonCancel"]
            XCTAssert(imageSourceAlertButtonCancel.exists)
            imageSourceAlertButtonCancel.tap()
        }

        let circleButton = app.buttons["CircleButton"]
        XCTAssert(circleButton.exists)

        let rectangleButton = app.buttons["RectangleButton"]
        XCTAssert(rectangleButton.exists)

        let multiStarButton = app.buttons["MultiStarButton"]
        XCTAssert(multiStarButton.exists)

        let starButton = app.buttons["StarButton"]
        XCTAssert(starButton.exists)

        let editStickerNavigationBar = app.navigationBars["EditStickerNavigationBar"]
        XCTAssert(editStickerNavigationBar.exists)

        let editStickerToolbar = app.toolbars["EditStickerToolbar"]
        XCTAssert(editStickerToolbar.exists)

        let saveButtonItem = editStickerNavigationBar.buttons["SaveButtonItem"]
        XCTAssert(saveButtonItem.exists)

        let cancelButtonItem = editStickerNavigationBar.buttons["CancelButtonItem"]
        XCTAssert(cancelButtonItem.exists)

        let deleteButtonItem = editStickerToolbar.buttons["DeleteButtonItem"]
        XCTAssert(deleteButtonItem.exists)

        let photoButtonItem = editStickerToolbar.buttons["PhotoButtonItem"]
        XCTAssert(photoButtonItem.exists)

        cancelButtonItem.tap()

        XCTAssert(collectionView.exists)

        let stickerCells = collectionView.cells.matching(identifier: "StickerCollectionCell")
        let firstStickerCell = stickerCells.element(boundBy: 0)
        XCTAssert(firstStickerCell.exists)

        firstStickerCell.tap()

        starButton.tap()
        multiStarButton.tap()
        rectangleButton.tap()

        snapshot("2_Edit_Sticker")

        circleButton.tap()

        saveButtonItem.tap()
    }

    func MessagesSnapshot() {
        guard let messageApp = XCUIApplication.eps_iMessagesApp() else {
            fatalError()
        }

        messageApp.launchArguments += ["-RunningUITests", "true"]
        setupSnapshot(messageApp)
        messageApp.launch()

        messageApp.tables.cells.element(boundBy: 0).tap()

        messageApp.buttons["browserButton"].tap()
        messageApp.children(matching: .window).element(boundBy: 0).tap()

        snapshot("3_Messages")
    }
}

// MARK: Helper

private extension PhotoStickersUITests {
    func isIPad() -> Bool {
        let window = XCUIApplication().windows.element(boundBy: 0)
        return window.horizontalSizeClass == .regular && window.verticalSizeClass == .regular
    }
}

extension XCUIElement {
    func forceTap() {
        if isHittable {
            tap()
        } else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0))
            coordinate.tap()
        }
    }

    // The following is a workaround for inputting text in the
    // simulator when the keyboard is hidden
    func setText(_ text: String, application: XCUIApplication) {
        UIPasteboard.general.string = text
        doubleTap()
        application.menuItems["Paste"].tap()
    }
}
