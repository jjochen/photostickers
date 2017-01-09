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
    
    lazy var viewModel: MessagesViewModel! = MessagesViewModel(extensionContext: self.extensionContext, managedObjectContext: CoreDataStack.shared.viewContext)
    
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
    }
}

// MARK: - Conversation Handling
extension MessagesViewController {

    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
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
    }

    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.didTransition(to: presentationStyle)
    }
}
