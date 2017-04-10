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
        setupSnapshot(app!)
        app!.launch()
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

        app.navigationBars.buttons["AddButton"].tap()
        snapshot("Edit Sticker Empty")
    }
}
