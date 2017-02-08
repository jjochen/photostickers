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

        self.window?.tintColor = Appearance.tintColor

        // todo: move into serviceProvider
        Realm.configureForAppGroup()
        let realm = try! Realm()

        let storyboard = UIStoryboard.app()
        let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController
        let stickerCollectionViewController = navigationController?.topViewController as? StickerCollectionViewController
        stickerCollectionViewController?.viewModel = StickerCollectionViewModel(realmContext: realm)
        //        viewController?.provider = provider
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}
