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

    func testUI() {
        app = XCUIApplication()
        guard let app = self.app else {
            fatalError()
        }

        app.launchArguments += ["-RunningUITests", "true"]
        setupSnapshot(app)
        app.launch()

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
        starButton.tap()
        multiStarButton.tap()
        rectangleButton.tap()

        snapshot("2_Edit_Sticker")

        circleButton.tap()

        saveButtonItem.tap()
    }

    func takeMessagesSnapshot() {
        app = XCUIApplication.eps_iMessagesApp()
        guard let app = self.app else {
            fatalError()
        }

        app.launchArguments += ["-RunningUITests", "true"]
        setupSnapshot(app)
        app.launch()

        app.tables.cells.element(boundBy: 0).tap()

        app.buttons["browserButton"].tap()
        app.children(matching: .window).element(boundBy: 0).tap()

        snapshot("3_Messages")
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
