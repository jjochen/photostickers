//
//  StickerBrowserFlow.swift
//  MessagesExtension
//
//  Created by Jochen on 02.04.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import Messages
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
        viewController.setNavigationBarHidden(true, animated: false)
        return viewController
    }()

    private let services: AppServices
    private let requestPresentationStyle: PublishSubject<MSMessagesAppPresentationStyle>
    private let currentPresentationStyle: Driver<MSMessagesAppPresentationStyle>

    init(withServices services: AppServices,
         requestPresentationStyle: PublishSubject<MSMessagesAppPresentationStyle>,
         currentPresentationStyle: Driver<MSMessagesAppPresentationStyle>) {
        self.services = services
        self.requestPresentationStyle = requestPresentationStyle
        self.currentPresentationStyle = currentPresentationStyle
    }

    deinit {
        print("\(type(of: self)): \(#function)")
    }

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? PhotoStickerStep else { return .none }

        switch step {
        case .stickerBrowserIsRequired:
            return navigateToStickerBrowser()
        case .addStickerIsPicked:
            return navigateToEditStickerScreen()
        case let .stickerIsPicked(sticker):
            return navigateToEditStickerScreen(with: sticker)
        default:
            return .none
        }
    }

    private func navigateToStickerBrowser() -> FlowContributors {
        let viewController = StickerBrowserViewController.instantiate(withViewModel: StickerBrowserViewModel(), andServices: services)
        viewController.requestPresentationStyle = requestPresentationStyle
        viewController.currentPresentationStyle = currentPresentationStyle

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

    private func navigateToEditStickerScreen(with sticker: Sticker? = nil) -> FlowContributors {
        let sticker = sticker ?? Sticker()
        let viewController = EditStickerViewController.instantiate(withViewModel: EditStickerViewModel(withSticker: sticker),
                                                                   andServices: services)
        rootViewController.present(viewController, animated: true)
        return .none
    }
}
