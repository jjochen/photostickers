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

class MessagesAppViewController: MSMessagesAppViewController, StoryboardBased, ViewModelBased {
    private lazy var application: Application = {
        guard let extensionContext = self.extensionContext else {
            fatalError("Extension Context not available")
        }
        return Application(extensionContext: extensionContext)
    }()

    lazy var viewModel: MessagesAppViewModel! = {
        let viewModel = MessagesAppViewModel()
        viewModel.services = application.appServices
        return viewModel
    }()

    private let disposeBag = DisposeBag()
    private let coordinator = FlowCoordinator()

    override func viewDidLoad() {
        super.viewDidLoad()

        RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) }
        view.tintColor = StyleKit.appColor

        setupBindings()

        let appFlow = StickerBrowserFlow(withServices: application.appServices)
        let appStepper = OneStepper(withSingleStep: PhotoStickerStep.stickerBrowserIsRequired)

        Flows.whenReady(flow1: appFlow) { [unowned self] root in
            self.embed(viewController: root)
        }

        coordinator.coordinate(flow: appFlow, with: appStepper)
    }

    private func setupBindings() {
        coordinator.rx.willNavigate.subscribe(onNext: { flow, step in
            print("will navigate to flow=\(flow) and step=\(step)")
        }).disposed(by: disposeBag)

        coordinator.rx.didNavigate.subscribe(onNext: { flow, step in
            print("did navigate to flow=\(flow) and step=\(step)")
        }).disposed(by: disposeBag)

        let presentationStyleWillChange = rx.willTransition.asDriver()

        let input = MessagesAppViewModel.Input(currentPresentationStyle: presentationStyleWillChange)

        _ = viewModel.transform(input: input)

//        output.presentationStyleRequested
//            .drive(rx.requestPresentationStyle)
//            .disposed(by: disposeBag)
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

        viewController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        viewController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        viewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        viewController.didMove(toParent: self)
    }
}
