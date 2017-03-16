//
//  ImageScrollView+Rx.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 04/03/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: ImageScrollView {

    var visibleRect: ControlEvent<CGRect> {
        let scrollView = self.base as UIScrollView
        let source = Observable.of(scrollView.rx.didScroll, scrollView.rx.didZoom)
            .merge()
            .map { () -> CGRect in
                return self.base.visibleRect
            }
        return ControlEvent(events: source)
    }

    var imageWithVisibleRect: UIBindingObserver<Base, ImageWithVisibleRect> {
        return UIBindingObserver(UIElement: base) { imageScrollView, imageWithVisibleRect in
            imageScrollView.imageWithVisibleRect = imageWithVisibleRect
        }
    }

    var cropRect: UIBindingObserver<Base, CGRect> {
        return UIBindingObserver(UIElement: base) { imageScrollView, cropRect in
            imageScrollView.cropRect = cropRect
        }
    }
}
