//
//  EditStickerFlow.swift
//  MessagesExtension
//
//  Created by Jochen on 02.04.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import RxCocoa
import RxFlow
import RxSwift
import UIKit

class EditStickerFlow: Flow {
    var root: Presentable {
        return rootViewController
    }

    private let rootViewController = UINavigationController()
    private let services: AppServices

    init(withServices services: AppServices) {
        self.services = services
    }

    deinit {
        print("\(type(of: self)): \(#function)")
    }

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? PhotoStickerStep else { return .none }

        switch step {
        default:
            return .none
        }
    }
}
