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
    lazy var viewModel: MessagesAppViewModelType = {
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

    fileprivate let disposeBag = DisposeBag()

    // MARK: Outlets / Actions

    override func viewDidLoad() {
        super.viewDidLoad()
        RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) }
        view.tintColor = StyleKit.appColor
        setupBindings()
    }

    // MARK: - Bindings

    fileprivate func setupBindings() {
        rx.willTransition
            .bind(to: viewModel.currentPresentationStyle)
            .disposed(by: disposeBag)

//        viewModel.requestPresentationStyle
//            .drive(rx.requestPresentationStyle)
//            .disposed(by: disposeBag)
    }
}

extension MessagesAppViewController {
    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> MessagesAppViewController {
        let viewController = storyboard.viewController(withID: .MessagesAppViewController) as! MessagesAppViewController
        return viewController
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        func getPhotoStickerBrowserViewController(from segue: UIStoryboardSegue) -> PhotoStickerBrowserViewController {
            let navigationController: UINavigationController = castOrFatalError(segue.destination)
            let viewController: PhotoStickerBrowserViewController = castOrFatalError(navigationController.topViewController)
            return viewController
        }

        if segue == .EmbedStickerBrowserSegue {
            let viewController = getPhotoStickerBrowserViewController(from: segue)
            viewController.viewModel = viewModel.stickerBrowserViewModel()
        }
    }
}
