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

    var maskPath: UIBindingObserver<Base, Mask?> {
        return UIBindingObserver(UIElement: base) { maskView, maskPath in
            maskView.maskPath = maskPath
        }
    }

    var maskRect: UIBindingObserver<Base, CGRect?> {
        return UIBindingObserver(UIElement: base) { maskView, maskRect in
            maskView.maskRect = maskRect
        }
    }
}
