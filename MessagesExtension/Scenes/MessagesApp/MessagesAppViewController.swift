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
import RxSwift
import UIKit

/* TODO:
 * check https://github.com/sergdort/CleanArchitectureRxSwift
 * show toolbar with edit/done button only in expanded mode
 * only in edit mode: edit, sort, delete sticker
 */

class MessagesAppViewController: MSMessagesAppViewController, StoryboardBased, ViewModelBased {
    lazy var application: Application = {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) }
        view.tintColor = StyleKit.appColor
        bindViewModel()
    }

    private func bindViewModel() {
        let presentationStyleWillChange = rx.willTransition.asDriver()

        let input = MessagesAppViewModel.Input(currentPresentationStyle: presentationStyleWillChange)

        let output = viewModel.transform(input: input)

        output.presentationStyleRequested
            .drive(rx.requestPresentationStyle)
            .disposed(by: disposeBag)
    }
}
