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
    public var contentInset: Binder<UIEdgeInsets> {
        return Binder(self.base) { scrollView, contentInset in
            scrollView.contentInset = contentInset
        }
    }

    public var maximumZoomScale: Binder<CGFloat> {
        return Binder(self.base) { scrollView, maximumZoomScale in
            scrollView.maximumZoomScale = maximumZoomScale
        }
    }

    public var minimumZoomScale: Binder<CGFloat> {
        return Binder(self.base) { scrollView, minimumZoomScale in
            scrollView.minimumZoomScale = minimumZoomScale
        }
    }

    public var zoomScale: Binder<CGFloat> {
        return Binder(self.base) { scrollView, zoomScale in
            scrollView.zoomScale = zoomScale
        }
    }
}
