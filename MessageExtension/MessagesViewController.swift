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

class MessagesViewController: MSMessagesAppViewController {

    var viewModel = MessagesViewModel()

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let photoStickerBrowserViewController = segue.destination as? PhotoStickerBrowserViewController else {
            Logger.shared.error("destination should be of class PhotoStickerBrowserViewController")
            return
        }

        photoStickerBrowserViewController.viewModel = self.viewModel.photoStickerBrowserViewModel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Conversation Handling

    override func willBecomeActive(with conversation: MSConversation) {
    }

    override func didResignActive(with conversation: MSConversation) {
    }

    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
    }

    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
    }

    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
    }

    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        self.view.setNeedsLayout()
    }

    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        self.view.setNeedsLayout()
    }
}
