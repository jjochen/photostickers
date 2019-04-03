//
//  MSMessagesAppViewController+Rx.swift
//  MessageExtension
//
//  Created by Jochen on 23.03.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import Messages
import RxCocoa
import RxSwift

public typealias WillSelectMessageEvent = (message: MSMessage, conversation: MSConversation)
public typealias DidSelectMessageEvent = (message: MSMessage, conversation: MSConversation)
public typealias DidReceiveMessageEvent = (message: MSMessage, conversation: MSConversation)
public typealias DidStartSendingMessageEvent = (message: MSMessage, conversation: MSConversation)
public typealias DidCancelSendingMessageEvent = (message: MSMessage, conversation: MSConversation)

public extension Reactive where Base: MSMessagesAppViewController {
    var requestPresentationStyle: Binder<MSMessagesAppPresentationStyle> {
        return Binder(base) { messagesAppViewController, presentationStyle in
            messagesAppViewController.requestPresentationStyle(presentationStyle)
        }
    }

    var conversationWillBecomeActive: ControlEvent<MSConversation> {
        let source = methodInvoked(#selector(Base.willBecomeActive(with:)))
            .map { a in
                try castOrThrow(MSConversation.self, a[0])
            }
        return ControlEvent(events: source)
    }

    var conversationDidBecomeActive: ControlEvent<MSConversation> {
        let source = methodInvoked(#selector(Base.didBecomeActive(with:)))
            .map { a in
                try castOrThrow(MSConversation.self, a[0])
            }
        return ControlEvent(events: source)
    }

    var conversationWillResignActive: ControlEvent<MSConversation> {
        let source = methodInvoked(#selector(Base.willResignActive(with:)))
            .map { a in
                try castOrThrow(MSConversation.self, a[0])
            }
        return ControlEvent(events: source)
    }

    var conversationDidResignActive: ControlEvent<MSConversation> {
        let source = methodInvoked(#selector(Base.didResignActive(with:)))
            .map { a in
                try castOrThrow(MSConversation.self, a[0])
            }
        return ControlEvent(events: source)
    }

    var conversationWillSelectMessage: ControlEvent<WillSelectMessageEvent> {
        let source: Observable<WillSelectMessageEvent> = methodInvoked(#selector(Base.willSelect(_:conversation:)))
            .map { a in
                (try castOrThrow(MSMessage.self, a[0]), try castOrThrow(MSConversation.self, a[1]))
            }
        return ControlEvent(events: source)
    }

    var conversationDidSelectMessage: ControlEvent<DidSelectMessageEvent> {
        let source: Observable<DidSelectMessageEvent> = methodInvoked(#selector(Base.didSelect(_:conversation:)))
            .map { a in
                (try castOrThrow(MSMessage.self, a[0]), try castOrThrow(MSConversation.self, a[1]))
            }
        return ControlEvent(events: source)
    }

    var conversationDidReceiveconversationDidCancelSendingMessage: ControlEvent<DidReceiveMessageEvent> {
        let source: Observable<DidReceiveMessageEvent> = methodInvoked(#selector(Base.didReceive(_:conversation:)))
            .map { a in
                (try castOrThrow(MSMessage.self, a[0]), try castOrThrow(MSConversation.self, a[1]))
            }
        return ControlEvent(events: source)
    }

    var conversationDidStartSendingconversationDidCancelSendingMessage: ControlEvent<DidStartSendingMessageEvent> {
        let source: Observable<DidStartSendingMessageEvent> = methodInvoked(#selector(Base.didStartSending(_:conversation:)))
            .map { a in
                (try castOrThrow(MSMessage.self, a[0]), try castOrThrow(MSConversation.self, a[1]))
            }
        return ControlEvent(events: source)
    }

    var conversationDidCancelSendingMessage: ControlEvent<DidCancelSendingMessageEvent> {
        let source: Observable<DidCancelSendingMessageEvent> = methodInvoked(#selector(Base.didCancelSending(_:conversation:)))
            .map { a in
                (try castOrThrow(MSMessage.self, a[0]), try castOrThrow(MSConversation.self, a[1]))
            }
        return ControlEvent(events: source)
    }

    var willTransitionToPresentationStyle: ControlEvent<MSMessagesAppPresentationStyle> {
        let source = methodInvoked(#selector(Base.willTransition(to:)))
            .map { a in
                MSMessagesAppPresentationStyle(rawValue: try castOrThrow(UInt.self, a[0]))!
            }
        return ControlEvent(events: source)
    }

    var didTransitionToPresentationStyle: ControlEvent<MSMessagesAppPresentationStyle> {
        let source = methodInvoked(#selector(Base.didTransition))
            .map { a in
                MSMessagesAppPresentationStyle(rawValue: try castOrThrow(UInt.self, a[0]))!
            }
        return ControlEvent(events: source)
    }
}
