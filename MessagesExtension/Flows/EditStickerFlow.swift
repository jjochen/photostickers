//
//  EditStickerFlow.swift
//  MessagesExtension
//
//  Created by Jochen on 02.04.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import RxCocoa
import RxFlow
import RxSwift
import UIKit

class EditStickerFlow: Flow {
    var root: Presentable {
        return rootViewController
    }

    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.setNavigationBarHidden(false, animated: false)
        viewController.setToolbarHidden(false, animated: false)
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
        case let .editStickerIsRequired(sticker):
            return navigateToEditStickerScreen(withSticker: sticker)
        case .editStickerComplete:
            return dismissViewController()
        default:
            return .none
        }
    }

    private func navigateToEditStickerScreen(withSticker sticker: Sticker) -> FlowContributors {
        let viewController = EditStickerViewController.instantiate(withViewModel: EditStickerViewModel(withSticker: sticker),
                                                                   andServices: services)

        rootViewController.pushViewController(viewController, animated: false)
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewController.viewModel))
    }

    private func dismissViewController() -> FlowContributors {
        rootViewController.dismiss(animated: true)
        return .none
    }
}
