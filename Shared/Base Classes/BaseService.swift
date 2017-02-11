//
//  BaseService.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 09/02/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation

class BaseService {
    unowned let provider: ServiceProviderType

    init(provider: ServiceProviderType) {
        self.provider = provider
    }
}
