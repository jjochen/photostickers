//
//  MessagesViewController.swift
//  MessageExtension
//
//  Created by Jochen Pfeiffer on 28/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import UIKit
import Messages
import Log
import RealmSwift

class MessagesViewController: MSMessagesAppViewController {

    lazy var viewModel: MessagesViewModelType = {
        let imageService = ImageStoreService(url: AppGroup.imagesURL)
        let stickerService = StickerService(realmURL: AppGroup.realmURL, imageStoreService: imageService)
        return MessagesViewModel(stickerService: stickerService, extensionContext: self.extensionContext)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.tintColor = Appearance.tintColor
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
        viewController.viewModel = self.viewModel.photoStickerBrowserViewModel()
        return viewController
    }

    fileprivate func presentViewController(for presentationStyle: MSMessagesAppPresentationStyle) {

        let controller: UIViewController
        if presentationStyle == .compact {
            controller = instantiatePhotoStickerBrowserViewController()
        } else {
            controller = instantiatePhotoStickerBrowserViewController()
        }

        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }

        addChildViewController(controller)

        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)

        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        controller.didMove(toParentViewController: self)
    }
}
