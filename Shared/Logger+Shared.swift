//
//  Log.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 01/01/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Log

extension Logger {

    static let shared = Logger(formatter: .default, theme: nil, minLevel: .trace)
}
