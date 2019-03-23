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

    var willBecomeActive: ControlEvent<MSConversation> {
        let source = methodInvoked(#selector(Base.willBecomeActive(with:)))
            .map { a in
                try castOrThrow(MSConversation.self, a[1])
            }
        return ControlEvent(events: source)
    }

    var didBecomeActive: ControlEvent<MSConversation> {
        let source = methodInvoked(#selector(Base.didBecomeActive(with:)))
            .map { a in
                try castOrThrow(MSConversation.self, a[1])
            }
        return ControlEvent(events: source)
    }

    var willResignActive: ControlEvent<MSConversation> {
        let source = methodInvoked(#selector(Base.willResignActive(with:)))
            .map { a in
                try castOrThrow(MSConversation.self, a[1])
            }
        return ControlEvent(events: source)
    }

    var didResignActive: ControlEvent<MSConversation> {
        let source = methodInvoked(#selector(Base.didResignActive(with:)))
            .map { a in
                try castOrThrow(MSConversation.self, a[1])
            }
        return ControlEvent(events: source)
    }

    var willSelect: ControlEvent<WillSelectMessageEvent> {
        let source: Observable<WillSelectMessageEvent> = methodInvoked(#selector(Base.willSelect(_:conversation:)))
            .map { a in
                (try castOrThrow(MSMessage.self, a[1]), try castOrThrow(MSConversation.self, a[2]))
            }
        return ControlEvent(events: source)
    }

    var didSelect: ControlEvent<DidSelectMessageEvent> {
        let source: Observable<DidSelectMessageEvent> = methodInvoked(#selector(Base.didSelect(_:conversation:)))
            .map { a in
                (try castOrThrow(MSMessage.self, a[1]), try castOrThrow(MSConversation.self, a[2]))
            }
        return ControlEvent(events: source)
    }

    var didReceive: ControlEvent<DidReceiveMessageEvent> {
        let source: Observable<DidReceiveMessageEvent> = methodInvoked(#selector(Base.didReceive(_:conversation:)))
            .map { a in
                (try castOrThrow(MSMessage.self, a[1]), try castOrThrow(MSConversation.self, a[2]))
            }
        return ControlEvent(events: source)
    }

    var didStartSending: ControlEvent<DidStartSendingMessageEvent> {
        let source: Observable<DidStartSendingMessageEvent> = methodInvoked(#selector(Base.didStartSending(_:conversation:)))
            .map { a in
                (try castOrThrow(MSMessage.self, a[1]), try castOrThrow(MSConversation.self, a[2]))
            }
        return ControlEvent(events: source)
    }

    var didCancelSending: ControlEvent<DidCancelSendingMessageEvent> {
        let source: Observable<DidCancelSendingMessageEvent> = methodInvoked(#selector(Base.didCancelSending(_:conversation:)))
            .map { a in
                (try castOrThrow(MSMessage.self, a[1]), try castOrThrow(MSConversation.self, a[2]))
            }
        return ControlEvent(events: source)
    }

    var willTransition: ControlEvent<MSMessagesAppPresentationStyle> {
        let source = methodInvoked(#selector(Base.willTransition(to:)))
            .map { a in
                try castOrThrow(MSMessagesAppPresentationStyle.self, a[1])
            }
        return ControlEvent(events: source)
    }

    var didTransition: ControlEvent<MSMessagesAppPresentationStyle> {
        let source = methodInvoked(#selector(Base.didTransition(to:)))
            .map { a in
                try castOrThrow(MSMessagesAppPresentationStyle.self, a[1])
            }
        return ControlEvent(events: source)
    }
}
