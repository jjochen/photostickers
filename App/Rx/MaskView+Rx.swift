//
//  MaskView+Rx.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 10/03/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: MaskView {

    var path: UIBindingObserver<Base, UIBezierPath> {
        return UIBindingObserver(UIElement: base) { maskView, path in
            maskView.path = path
        }
    }
}
