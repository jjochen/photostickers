//
//  MessagesAppViewController.swift
//  MessageExtension
//
//  Created by Jochen on 28.03.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import Log
import Messages
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

/* TODO:
 * check https://github.com/sergdort/CleanArchitectureRxSwift
 * show toolbar with edit/done button only in expanded mode
 * only in edit mode: edit, sort, delete sticker
 */

class MessagesAppViewController: MSMessagesAppViewController {

    // ToDo: move to Application
    lazy var viewModel: MessagesAppViewModel = {
        #if DEBUG
            let isRunningUITests = true
        #else
            // TODO:
            let isRunningUITests = UserDefaults.standard.bool(forKey: "RunningUITests")
        #endif
        let dataFolderType: DataFolderType = isRunningUITests ? .appGroupPrefilled(subfolder: "UITests") : .appGroup
        let dataFolder: DataFolderServiceType = DataFolderService(type: dataFolderType)
        let imageStoreService: ImageStoreServiceType = ImageStoreService(url: dataFolder.imagesURL)
        let stickerService: StickerServiceType = StickerService(realmType: .onDisk(url: dataFolder.realmURL), imageStoreService: imageStoreService)
        let stickerRenderService: StickerRenderServiceType = StickerRenderService()
        let extensionContext = self.extensionContext

        return MessagesAppViewModel(stickerService: stickerService,
                                    imageStoreService: imageStoreService,
                                    stickerRenderService: stickerRenderService,
                                    extensionContext: extensionContext)
    }()

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) }
        view.tintColor = StyleKit.appColor
        bindViewModel()
    }


    private func bindViewModel() {
        //let presentationStyleWillChange = rx.willTransition.asDriver()

        let input = MessagesAppViewModel.Input()

        let output = viewModel.transform(input: input)

        output.presentationStyleRequested
            .drive(rx.requestPresentationStyle)
            .disposed(by: disposeBag)
    }
}

extension MessagesAppViewController {
    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> MessagesAppViewController {
        let viewController = storyboard.viewController(withID: .MessagesAppViewController) as! MessagesAppViewController
        return viewController
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        func getStickerBrowserViewController(from segue: UIStoryboardSegue) -> StickerBrowserViewController {
            let navigationController: UINavigationController = castOrFatalError(segue.destination)
            let viewController: StickerBrowserViewController = castOrFatalError(navigationController.topViewController)
            return viewController
        }

        if segue == .EmbedStickerBrowserSegue {
            let viewController = getStickerBrowserViewController(from: segue)
            viewController.viewModel = viewModel.stickerBrowserViewModel()
        }
    }
}
