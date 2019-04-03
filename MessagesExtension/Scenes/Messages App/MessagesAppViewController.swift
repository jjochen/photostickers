//
//  MessagesAppViewController.swift
//  MessageExtension
//
//  Created by Jochen on 28.03.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import Log
import Messages
import Reusable
import RxCocoa
import RxDataSources
import RxFlow
import RxSwift
import UIKit

/* TODO:
 * check https://github.com/sergdort/CleanArchitectureRxSwift
 * show toolbar with edit/done button only in expanded mode
 * only in edit mode: edit, sort, delete sticker
 */

class MessagesAppViewController: MSMessagesAppViewController, StoryboardBased {
    private lazy var application: Application = {
        Application()
    }()

    private let disposeBag = DisposeBag()
    private let coordinator = FlowCoordinator()
    private let requestPresentationStyle = PublishSubject<MSMessagesAppPresentationStyle>()

    override func viewDidLoad() {
        super.viewDidLoad()

        RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) }
        view.tintColor = StyleKit.appColor

        setupFlow()
    }

    private func setupFlow() {
        coordinator.rx.willNavigate.subscribe(onNext: { flow, step in
            print("will navigate to flow=\(flow) and step=\(step)")
        }).disposed(by: disposeBag)

        coordinator.rx.didNavigate.subscribe(onNext: { flow, step in
            print("did navigate to flow=\(flow) and step=\(step)")
        }).disposed(by: disposeBag)

        requestPresentationStyle.asDriver(onErrorDriveWith: Driver.empty())
            .drive(rx.requestPresentationStyle)
            .disposed(by: disposeBag)

        let appFlow = StickerBrowserFlow(withServices: application.appServices,
                                         requestPresentationStyle: requestPresentationStyle,
                                         currentPresentationStyle: rx.willTransitionToPresentationStyle.asDriver())
        let appStepper = OneStepper(withSingleStep: PhotoStickerStep.stickerBrowserIsRequired)

        Flows.whenReady(flow1: appFlow) { [unowned self] root in
            self.embed(viewController: root)
        }

        coordinator.coordinate(flow: appFlow, with: appStepper)
    }
}

extension MessagesAppViewController {
    private func embed(viewController: UIViewController) {
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }

        addChild(viewController)

        viewController.view.frame = view.bounds
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewController.view)

        NSLayoutConstraint.activate([
            viewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            viewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        viewController.didMove(toParent: self)
    }
}
