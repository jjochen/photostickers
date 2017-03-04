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

// MARK: - Rx
extension Reactive where Base: ImageScrollView {

    var didZoomToVisibleRect: ControlEvent<CGRect> {
        let scrollView = self.base as UIScrollView
        let source = Observable.of(scrollView.rx.didScroll, scrollView.rx.didZoom)
            .merge()
            .map { () -> CGRect in
                return self.base.visibleRect
            }
        return ControlEvent(events: source)
    }

    var image: UIBindingObserver<Base, UIImage?> {
        return image(transitionType: nil)
    }

    func image(transitionType: String? = nil) -> UIBindingObserver<Base, UIImage?> {
        return UIBindingObserver(UIElement: base) { imageScrollView, image in
            if let transitionType = transitionType {
                if image != nil {
                    let transition = CATransition()
                    transition.duration = 0.25
                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    transition.type = transitionType
                    imageScrollView.layer.add(transition, forKey: kCATransition)
                }
            } else {
                imageScrollView.layer.removeAllAnimations()
            }
            imageScrollView.image = image
        }
    }
}
