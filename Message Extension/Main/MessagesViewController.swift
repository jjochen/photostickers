//
//  MessagesViewController.swift
//  MessageExtension
//
//  Created by Jochen Pfeiffer on 28/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Log
import Messages
import RealmSwift
import UIKit

class MessagesViewController: MSMessagesAppViewController {
    lazy var viewModel: MessagesViewModelType = {
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
        return MessagesViewModel(stickerService: stickerService, imageStoreService: imageStoreService, extensionContext: self.extensionContext)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = StyleKit.appColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Conversation Handling

extension MessagesViewController {
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        presentViewController(for: presentationStyle)
    }

    override func didResignActive(with conversation: MSConversation) {
        super.didResignActive(with: conversation)
    }

    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        super.didReceive(message, conversation: conversation)
    }

    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        super.didStartSending(message, conversation: conversation)
    }

    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        super.didCancelSending(message, conversation: conversation)
    }

    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.willTransition(to: presentationStyle)
        presentViewController(for: presentationStyle)
    }

    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.didTransition(to: presentationStyle)
    }
}

// MARK: Child view controller presentation

extension MessagesViewController {
    fileprivate func instantiatePhotoStickerBrowserViewController() -> PhotoStickerBrowserViewController {
        let viewController = PhotoStickerBrowserViewController.instantiateFromStoryboard(UIStoryboard.messageExtension())
        viewController.viewModel = viewModel.photoStickerBrowserViewModel()
        return viewController
    }

    fileprivate func presentViewController(for presentationStyle: MSMessagesAppPresentationStyle) {
        let controller: UIViewController
        if presentationStyle == .compact {
            controller = instantiatePhotoStickerBrowserViewController()
        } else {
            controller = instantiatePhotoStickerBrowserViewController()
        }

        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }

        addChild(controller)

        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)

        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        controller.didMove(toParent: self)
    }
}
