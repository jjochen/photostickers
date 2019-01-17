//
//  UIScrollView+Rx.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 28.03.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UIScrollView {
    public var contentInset: UIBindingObserver<Base, UIEdgeInsets> {
        return UIBindingObserver(UIElement: base) { scrollView, contentInset in
            scrollView.contentInset = contentInset
        }
    }

    public var maximumZoomScale: UIBindingObserver<Base, CGFloat> {
        return UIBindingObserver(UIElement: base) { scrollView, maximumZoomScale in
            scrollView.maximumZoomScale = maximumZoomScale
        }
    }

    public var minimumZoomScale: UIBindingObserver<Base, CGFloat> {
        return UIBindingObserver(UIElement: base) { scrollView, minimumZoomScale in
            scrollView.minimumZoomScale = minimumZoomScale
        }
    }

    public var zoomScale: UIBindingObserver<Base, CGFloat> {
        return UIBindingObserver(UIElement: base) { scrollView, zoomScale in
            scrollView.zoomScale = zoomScale
        }
    }
}
