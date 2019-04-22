//
//  UIImagePickerController+Rx.swift
//  RxExample
//
//  Created by Segii Shulga on 1/4/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UIImagePickerController {
    /**
     Reactive wrapper for `delegate` message.
     */
    public var didFinishPickingMediaWithInfo: Observable<[String: AnyObject]> {
        return delegate
            .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:)))
            .map { a in
                try castOrThrow([String: AnyObject].self, a[1])
            }
    }

    /**
     Reactive wrapper for `delegate` message.
     */
    public var didCancel: Observable<()> {
        return delegate
            .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:)))
            .map { _ in () }
    }
}
