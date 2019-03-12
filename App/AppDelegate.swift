//
//  AppDelegate.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 28/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Log
import RealmSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let isRunningUnitTests = NSClassFromString("XCTest") != nil
        let isRunningUITests = UserDefaults.standard.bool(forKey: "RunningUITests")

        if isRunningUnitTests {
            return true
        }

        window?.backgroundColor = UIColor.white
        window?.tintColor = StyleKit.appColor

        RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) }

        let dataFolderType: DataFolderType = isRunningUITests ? .appGroupPrefilled(subfolder: "UITests") : .appGroup
        let dataFolder: DataFolderServiceType = DataFolderService(type: dataFolderType)

        let imageStoreService: ImageStoreServiceType = ImageStoreService(url: dataFolder.imagesURL)
        let stickerService: StickerServiceType = StickerService(realmType: .onDisk(url: dataFolder.realmURL), imageStoreService: imageStoreService)
        let stickerRenderService: StickerRenderServiceType = StickerRenderService()

        let storyboard = UIStoryboard.app()
        let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController
        let stickerCollectionViewController = navigationController?.topViewController as? StickerCollectionViewController
        stickerCollectionViewController?.viewModel = StickerCollectionViewModel(imageStoreService: imageStoreService, stickerService: stickerService, stickerRenderService: stickerRenderService)

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.absoluteString.contains("create") {
            Logger.shared.info("should create new sticker")
            // TODO:
        }
        return false
    }
}
