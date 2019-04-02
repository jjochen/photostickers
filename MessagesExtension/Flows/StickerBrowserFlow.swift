//
//  StickerBrowserFlow.swift
//  MessagesExtension
//
//  Created by Jochen on 02.04.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import RxCocoa
import RxFlow
import RxSwift
import UIKit

class StickerBrowserFlow: Flow {
    var root: Presentable {
        return rootViewController
    }

    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.setNavigationBarHidden(false, animated: false) // todo: hide by default
        return viewController
    }()

    private let services: AppServices

    init(withServices services: AppServices) {
        self.services = services
    }

    deinit {
        print("\(type(of: self)): \(#function)")
    }

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? PhotoStickerStep else { return .none }

        switch step {
        case .stickerBrowserIsRequired:
            return navigateToStickerBrowser()
        }
    }

    private func navigateToStickerBrowser() -> FlowContributors {
        let viewController = StickerBrowserViewController.instantiate(withViewModel: StickerBrowserViewModel(), andServices: services)
        rootViewController.pushViewController(viewController, animated: false)

//        if let navigationBarItem = self.rootViewController.navigationBar.items?[0] {
//            navigationBarItem.setRightBarButton(UIBarButtonItem(image: UIImage(named: "settings"),
//                                                                style: UIBarButtonItem.Style.plain,
//                                                                target: self.wishlistStepper,
//                                                                action: #selector(WishlistStepper.settingsAreRequired)),
//                                                animated: false)
//            navigationBarItem.setLeftBarButton(UIBarButtonItem(title: "Logout",
//                                                               style: UIBarButtonItem.Style.plain,
//                                                               target: self,
//                                                               action: #selector(WishlistFlow.logoutIsRequired)),
//                                               animated: false)
//        }
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewController.viewModel))
    }
}
