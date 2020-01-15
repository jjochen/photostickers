//
//  ImageScrollView+Rx.swift
//  MessagesExtension
//
//  Created by Jochen on 14.01.20.
//  Copyright © 2020 Jochen Pfeiffer. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: ImageScrollView {
    var delegate: DelegateProxy<ImageScrollView, ImageScrollViewDelegate> {
        return RxImageScrollViewDelegateProxy.proxy(for: base)
    }

    var visibleRect: ControlProperty<CGRect> {
        let proxy = RxImageScrollViewDelegateProxy.proxy(for: base)

        let bindingObserver = Binder(base) { scrollView, visibleRect in
            scrollView.visibleRect = visibleRect
        }

        return ControlProperty(values: proxy.visibleRectBehaviorSubject, valueSink: bindingObserver)
    }

    var visibleRectDidChange: ControlEvent<Void> {
        let source = RxImageScrollViewDelegateProxy.proxy(for: base).visibleRectPublishSubject
        return ControlEvent(events: source)
    }

    func setDelegate(_ delegate: ImageScrollViewDelegate)
        -> Disposable {
        return RxImageScrollViewDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: base)
    }
}
