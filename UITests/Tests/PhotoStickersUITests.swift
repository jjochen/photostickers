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

        let partySticker = messageApp.collectionViews["StickerBrowserCollectionView"].cells.element(boundBy: 5)
        let messageCell = messageApp.collectionViews["TranscriptCollectionView"].cells.matching(NSPredicate(format: "label CONTAINS[c] %@", messageText)).firstMatch
        let cellWidth = messageCell.frame.size.width
        let rightDX = CGFloat(130)
        let relativeDX = 1 - rightDX / cellWidth
        let sourceCoordinate: XCUICoordinate = partySticker.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.1))
        let destCorodinate: XCUICoordinate = messageCell.coordinate(withNormalizedOffset: CGVector(dx: relativeDX, dy: 0.0))
        sourceCoordinate.press(forDuration: 0.5, thenDragTo: destCorodinate)

        sleep(1)
        snapshot("1_Messages", timeWaitingForIdle: 40)

        messageApp.otherElements["collapseButtonIdentifier"].tap()
        sleep(1)
        snapshot("2_Sticker_Collection", timeWaitingForIdle: 40)

        messageApp.buttons["StickerBrowserEditBarButtonItem"].tap()
        messageApp.collectionViews["StickerBrowserCollectionView"].cells.element(boundBy: 0).tap()
        sleep(1)
        messageApp.buttons["RectangleButton"].tap()
        snapshot("3_Edit_Sticker")
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
