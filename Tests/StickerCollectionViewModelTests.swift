//
//  StickerCollectionViewModelTests.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 16.04.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Quick
import Nimble
import RxSwift
import RxCocoa
import RxNimble
import RxBlocking
@testable
import PhotoStickers

class StickerCollectionViewModelTests: QuickSpec {
    override func spec() {
        describe("the sticker collection view model") {

            var subject: StickerCollectionViewModelType!
            var stickerService: StickerServiceMock!
            var imageStoreService: ImageStoreServiceMock!
            var stickerRenderService: StickerRenderServiceMock!
            var disposeBag: DisposeBag!

            let didShowAlert = Variable(false)

            beforeEach {
                stickerRenderService = StickerRenderServiceMock()
                imageStoreService = ImageStoreServiceMock()
                stickerService = StickerServiceMock()
                disposeBag = DisposeBag()

                subject = StickerCollectionViewModel(imageStoreService: imageStoreService, stickerService: stickerService, stickerRenderService: stickerRenderService)

                didShowAlert.value = false
                subject.presentFirstStickerAlert
                    .map { true }
                    .drive(didShowAlert)
                    .disposed(by: disposeBag)
            }

            afterEach {
                subject = nil
            }

            context("when it's empty") {
                beforeEach {
                    stickerService.set(mockedStickers: [])
                }
                it("points to the add button") {
                    let result = try! subject.arrowHidden.toBlocking().first()!
                    expect(result) == false
                }
                it("doesn't show the info alert") {
                    expect(didShowAlert.value) == false
                }
            }

            context("when the first sticker is added") {
                beforeEach {
                    let sticker = Sticker()
                    stickerService.set(mockedStickers: [sticker])
                }
                it("shows the info alert") {
                    expect(didShowAlert.value) == true
                }

                it("doesn't point to the add button") {
                    let sticker = Sticker()
                    stickerService.set(mockedStickers: [sticker])

                    let result = try! subject.arrowHidden.toBlocking().first()!
                    expect(result) == true
                }
            }

            context("when there are stickers") {
                beforeEach {
                    let sticker1 = Sticker()
                    let sticker2 = Sticker()
                    let sticker3 = Sticker()
                    stickerService.set(mockedStickers: [sticker1, sticker2, sticker3])
                }
                it("doesn't show the info alert") {
                    expect(didShowAlert.value) == false
                }
                it("has the correct number of cells") {
                    let result = try! subject.stickerCellModels.toBlocking().first()!
                    expect(result.count) == 3
                }

                it("doesn't point to the add button") {
                    let result = try! subject.arrowHidden.toBlocking().first()!
                    expect(result) == true
                }
            }
        }
    }
}
