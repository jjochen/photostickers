//
//  PhotoStickersUITests.swift
//  PhotoStickersUITests
//
//  Created by Jochen Pfeiffer on 28/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import XCTest

class PhotoStickersUITests: XCTestCase {
    func testMessagesExtension() {
//
//        let stickerCollectionNavigtionBar = app.navigationBars["StickerCollectionNavigtionBar"]
//        XCTAssert(stickerCollectionNavigtionBar.exists)
//
//        let collectionView = app.collectionViews["StickerCollectionView"]
//        XCTAssert(collectionView.exists)
//
//        snapshot("4_Sticker_Collection")
//
//        let addButtonItem = stickerCollectionNavigtionBar.buttons["AddButtonItem"]
//        XCTAssert(addButtonItem.exists)
//
//        addButtonItem.tap()
//
//        sleep(1)
//
//        let sheetsQuery = app.sheets
//
//        let imageSourceAlertButtonPhotoLibrary = sheetsQuery.buttons["ImageSourceAlertButtonPhotoLibrary"]
//        XCTAssert(imageSourceAlertButtonPhotoLibrary.exists)
//
//        let imageSourceAlertButtonCamera = sheetsQuery.buttons["ImageSourceAlertButtonCamera"]
//        XCTAssert(imageSourceAlertButtonCamera.exists)
//
//        snapshot("2_Sticker_Source")
//
//        if isIPad() {
//            let appWindow = app.children(matching: .window).element(boundBy: 0)
//            appWindow.tap()
//        } else {
//            let imageSourceAlertButtonCancel = sheetsQuery.buttons["ImageSourceAlertButtonCancel"]
//            XCTAssert(imageSourceAlertButtonCancel.exists)
//            imageSourceAlertButtonCancel.tap()
//        }
//
//        sleep(1)
//
//        let circleButton = app.buttons["CircleButton"]
//        XCTAssert(circleButton.exists)
//
//        let rectangleButton = app.buttons["RectangleButton"]
//        XCTAssert(rectangleButton.exists)
//
//        let multiStarButton = app.buttons["MultiStarButton"]
//        XCTAssert(multiStarButton.exists)
//
//        let starButton = app.buttons["StarButton"]
//        XCTAssert(starButton.exists)
//
//        let editStickerNavigationBar = app.navigationBars["EditStickerNavigationBar"]
//        XCTAssert(editStickerNavigationBar.exists)
//
//        let editStickerToolbar = app.toolbars["EditStickerToolbar"]
//        XCTAssert(editStickerToolbar.exists)
//
//        let saveButtonItem = editStickerNavigationBar.buttons["SaveButtonItem"]
//        XCTAssert(saveButtonItem.exists)
//
//        let cancelButtonItem = editStickerNavigationBar.buttons["CancelButtonItem"]
//        XCTAssert(cancelButtonItem.exists)
//
//        let deleteButtonItem = editStickerToolbar.buttons["DeleteButtonItem"]
//        XCTAssert(deleteButtonItem.exists)
//
//        let photoButtonItem = editStickerToolbar.buttons["PhotoButtonItem"]
//        XCTAssert(photoButtonItem.exists)
//
//        cancelButtonItem.tap()
//
//        sleep(1)
//
//        let stickerCells = collectionView.cells.matching(identifier: "StickerCollectionCell")
//        let firstStickerCell = stickerCells.element(boundBy: 0)
//        XCTAssert(firstStickerCell.exists)
//
//        firstStickerCell.tap()
//
//        sleep(1)
//
//        starButton.tap()
//        multiStarButton.tap()
//        rectangleButton.tap()
//
//        snapshot("3_Edit_Sticker")
//
//        circleButton.tap()
//
//        saveButtonItem.tap()

        guard let messageApp = XCUIApplication.eps_iMessagesApp() else {
            fatalError()
        }

        messageApp.terminate()

        messageApp.launchArguments += ["-RunningUITests", "true"]
        setupSnapshot(messageApp)
        messageApp.launch()

        var continueButton = messageApp.buttons["Fortfahren"]
        if continueButton.exists {
            continueButton.tap()
        }
        continueButton = messageApp.buttons["Continue"]
        if continueButton.exists {
            continueButton.tap()
        }

        messageApp.tables["ConversationList"].cells.firstMatch.tap()

        sleep(1)

        messageApp.textFields["messageBodyField"].tap()
        let messageText = "🎉🎉🎉 Party?"
        messageApp.typeText(messageText)

        sleep(1)

        messageApp.buttons["sendButton"].tap()

        sleep(1)

        let appCells = messageApp.collectionViews["appSelectionBrowserIdentifier"].cells
        let photoStickersCell = appCells.matching(NSPredicate(format: "label CONTAINS[c] 'Photo Stickers'")).firstMatch
        photoStickersCell.tap()

        sleep(2)

        let sticker = messageApp.collectionViews["StickerBrowserCollectionView"].cells.element(boundBy: 5)
        let messageCell = messageApp.collectionViews["TranscriptCollectionView"].cells.matching(NSPredicate(format: "label CONTAINS[c] %@", messageText)).firstMatch
        let cellWidth = messageCell.frame.size.width
        let rightDX = CGFloat(130)
        let relativeDX = 1 - rightDX / cellWidth
        let sourceCoordinate: XCUICoordinate = sticker.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.1))
        let destCorodinate: XCUICoordinate = messageCell.coordinate(withNormalizedOffset: CGVector(dx: relativeDX, dy: 0.5))
        sourceCoordinate.press(forDuration: 0.5, thenDragTo: destCorodinate)

        sleep(1)

        snapshot("1_Messages", timeWaitingForIdle: 40)
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

    func dragAndDropUsingCenterPos(forDuration duration: TimeInterval, thenDragTo destElement: XCUIElement) {
        let sourceCoordinate: XCUICoordinate = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))

        let destCorodinate: XCUICoordinate = destElement.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))

        sourceCoordinate.press(forDuration: duration, thenDragTo: destCorodinate)
    }
}
