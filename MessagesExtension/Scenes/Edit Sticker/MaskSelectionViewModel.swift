//
//  MaskSelectionViewModel.swift
//  MessagesExtension
//
//  Created by Jochen on 27.12.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import RxCocoa
import RxOptional
import RxSwift

final class MaskSelectionViewModel: ServicesViewModel {
    typealias Services = AppServices
    var services: AppServices!

    struct Input {
        let circleButtonDidTap: Driver<Void>
        let rectangleButtonDidTap: Driver<Void>
        let starButtonDidTap: Driver<Void>
        let multiStarButtonDidTap: Driver<Void>
    }

    struct Output {
        let mask: Driver<Mask>
    }

    func transform(input: Input) -> Output {
        let mask = Driver
            .of(input.circleButtonDidTap.map { Mask.circle },
                input.rectangleButtonDidTap.map { Mask.rectangle },
                input.starButtonDidTap.map { Mask.star },
                input.multiStarButtonDidTap.map { Mask.multiStar })
            .merge()

        return Output(mask: mask)
    }
}
