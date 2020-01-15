//
//  RXImageScrollViewDelegateProxy.swift
//  MessagesExtension
//
//  Created by Jochen on 14.01.20.
//  Copyright © 2020 Jochen Pfeiffer. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

extension ImageScrollView: HasDelegate {
    typealias Delegate = ImageScrollViewDelegate
}

class RxImageScrollViewDelegateProxy:
    DelegateProxy<ImageScrollView, ImageScrollViewDelegate>,
    DelegateProxyType,
    ImageScrollViewDelegate {
    private(set) weak var imageScrollView: ImageScrollView?

    init(imageScrollView: ParentObject) {
        self.imageScrollView = imageScrollView
        super.init(parentObject: imageScrollView, delegateProxy: RxImageScrollViewDelegateProxy.self)
    }

    static func registerKnownImplementations() {
        register { RxImageScrollViewDelegateProxy(imageScrollView: $0) }
    }

    private var _visibleRectBehaviorSubject: BehaviorSubject<CGRect>?
    private var _visibleRectPublishSubject: PublishSubject<Void>?

    var visibleRectBehaviorSubject: BehaviorSubject<CGRect> {
        if let subject = _visibleRectBehaviorSubject {
            return subject
        }

        let subject = BehaviorSubject<CGRect>(value: imageScrollView?.visibleRect ?? CGRect.zero)
        _visibleRectBehaviorSubject = subject

        return subject
    }

    var visibleRectPublishSubject: PublishSubject<Void> {
        if let subject = _visibleRectPublishSubject {
            return subject
        }

        let subject = PublishSubject<Void>()
        _visibleRectPublishSubject = subject

        return subject
    }

    // MARK: delegate methods

    func imageScrollView(_ imageScrollView: ImageScrollView, didChangeVisibleRect rect: CGRect) {
        if let subject = _visibleRectBehaviorSubject {
            subject.on(.next(rect))
        }
        if let subject = _visibleRectPublishSubject {
            subject.on(.next(()))
        }

        forwardToDelegate()?.imageScrollView(imageScrollView, didChangeVisibleRect: rect)
    }

    deinit {
        if let subject = _visibleRectBehaviorSubject {
            subject.on(.completed)
        }

        if let subject = _visibleRectPublishSubject {
            subject.on(.completed)
        }
    }
}
