//
//  AppDelegate.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 28/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        if let _ = NSClassFromString("XCTest") { return true }

        self.window?.backgroundColor = UIColor.white
        self.window?.tintColor = Appearance.tintColor

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
}
