//
//  UIViewController+Rx.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 24/03/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit

import RxSwift

extension Reactive where Base: UIViewController {

    var viewDidLoad: Observable<Void> {
        return sentMessage(#selector(Base.viewDidLoad)).map { _ in Void() }
    }

    var viewWillAppear: Observable<Bool> {
        return sentMessage(#selector(Base.viewWillAppear)).map { $0.first as? Bool ?? false }
    }

    var viewDidAppear: Observable<Bool> {
        return sentMessage(#selector(Base.viewDidAppear)).map { $0.first as? Bool ?? false }
    }

    var viewWillDisappear: Observable<Bool> {
        return sentMessage(#selector(Base.viewWillDisappear)).map { $0.first as? Bool ?? false }
    }

    var viewDidDisappear: Observable<Bool> {
        return sentMessage(#selector(Base.viewDidDisappear)).map { $0.first as? Bool ?? false }
    }

    var viewWillLayoutSubviews: Observable<Void> {
        return sentMessage(#selector(Base.viewWillLayoutSubviews)).map { _ in Void() }
    }

    var viewDidLayoutSubviews: Observable<Void> {
        return sentMessage(#selector(Base.viewDidLayoutSubviews)).map { _ in Void() }
    }
}
