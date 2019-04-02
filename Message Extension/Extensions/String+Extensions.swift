//
//  String+Extensions.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 08.04.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return localized()
    }

    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
}
