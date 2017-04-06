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

        if let _ = NSClassFromString("XCTest") { return true }

        window?.backgroundColor = UIColor.white
        window?.tintColor = StyleKit.appColor

        let imageStoreService = ImageStoreService(url: AppGroup.imagesURL)
        let stickerService = StickerService(realmURL: AppGroup.realmURL, imageStoreService: imageStoreService)
        let stickerRenderService = StickerRenderService()

        let storyboard = UIStoryboard.app()
        let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController
        let stickerCollectionViewController = navigationController?.topViewController as? StickerCollectionViewController
        stickerCollectionViewController?.viewModel = StickerCollectionViewModel(imageStoreService: imageStoreService, stickerService: stickerService, stickerRenderService: stickerRenderService)

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.absoluteString == "photosticker://create" {
            Logger.shared.info("oppened from message extension")
            // TODO:
        }
        return false
    }
}
