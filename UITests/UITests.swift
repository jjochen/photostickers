//
//  UITests.swift
//  UITests
//
//  Created by Jochen on 17.07.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import XCTest

class UITests: XCTestCase {
    func testExample() {
        let messageApp = XCUIApplication(bundleIdentifier: "com.apple.MobileSMS")

        messageApp.terminate()

        messageApp.launchArguments += ["-RunningUITests", "true"]
        // setupSnapshot(messageApp)
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

        // photoStickersCell.tap()
    }
}
