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
        viewController.view.tintColor = StyleKit.appColor
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
            return navigateToStickerBrowserScreen()
        case .addStickerIsPicked:
            return navigateToEditStickerScreen()
        case let .stickerIsPicked(sticker):
            return navigateToEditStickerScreen(with: sticker)
        default:
            return .none
        }
    }

    private func navigateToStickerBrowserScreen() -> FlowContributors {
        let viewController = StickerBrowserViewController.instantiate(withViewModel: StickerBrowserViewModel(), andServices: services)
        viewController.requestPresentationStyle = requestPresentationStyle
        viewController.currentPresentationStyle = currentPresentationStyle

        rootViewController.pushViewController(viewController, animated: false)
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewController.viewModel))
    }

    private func navigateToEditStickerScreen(with sticker: Sticker? = nil) -> FlowContributors {
        let existingOrNewSticker = sticker ?? Sticker()

        let editStickerFlow = EditStickerFlow(withServices: services)

        Flows.whenReady(flow1: editStickerFlow) { [unowned self] root in
            self.rootViewController.present(root, animated: true, completion: nil)
        }

        return .one(flowContributor: .contribute(withNextPresentable: editStickerFlow,
                                                 withNextStepper: OneStepper(withSingleStep: PhotoStickerStep.editStickerIsRequired(existingOrNewSticker))))
    }
}
