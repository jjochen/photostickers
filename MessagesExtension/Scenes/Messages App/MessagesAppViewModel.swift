//
//  MessagesAppViewModel.swift
//  MessageExtension
//
//  Created by Jochen on 28.03.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import Log
import Messages
import RealmSwift
import RxCocoa
import RxRealm
import RxSwift

final class MessagesAppViewModel: ServicesViewModel {
    typealias Services = AppServices
    struct Input {
        let currentPresentationStyle: Driver<MSMessagesAppPresentationStyle>
    }

    struct Output {
        let presentationStyleRequested: Driver<MSMessagesAppPresentationStyle>
    }

    var services: AppServices!

    func transform(input _: Input) -> Output {
        return Output(presentationStyleRequested: nil)
    }
}
