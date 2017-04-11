//
//  AppDelegate.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 28/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import UIKit
import RealmSwift
import Log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let isRunningUnitTests = NSClassFromString("XCTest") != nil
        let isRunningUITests = UserDefaults.standard.bool(forKey: "RunningUITests")

        if isRunningUnitTests {
            window?.backgroundColor = UIColor.red
            return true
        }

        window?.backgroundColor = UIColor.white
        window?.tintColor = StyleKit.appColor

        let dataFolderType: DataFolderType = isRunningUITests ? .temporary : .appGroup
        let dataFolder: DataFolderServiceType = DataFolderService(type: dataFolderType)

        let imageStoreService: ImageStoreServiceType = ImageStoreService(url: dataFolder.imagesURL)
        let stickerService: StickerServiceType = StickerService(realmType: .onDisk(url: dataFolder.realmURL), imageStoreService: imageStoreService)
        let stickerRenderService: StickerRenderServiceType = StickerRenderService()

        if isRunningUITests {
            resetDataFolder(dataFolder.url)
        }

        let storyboard = UIStoryboard.app()
        let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController
        let stickerCollectionViewController = navigationController?.topViewController as? StickerCollectionViewController
        stickerCollectionViewController?.viewModel = StickerCollectionViewModel(imageStoreService: imageStoreService, stickerService: stickerService, stickerRenderService: stickerRenderService)

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.absoluteString.contains("create") {
            Logger.shared.info("should create new sticker")
            // TODO:
        }
        return false
    }
}

fileprivate extension AppDelegate {
    func resetDataFolder(_: URL?) {
    }
}
