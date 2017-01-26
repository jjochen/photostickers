//
//  Sticker+CoreDataProperties.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 01/01/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import RealmSwift
import RxDataSources
import Log

func == (lhs: Sticker, rhs: Sticker) -> Bool {
    return lhs.uuid == rhs.uuid // check
}

extension Sticker: IdentifiableType {
    typealias Identity = String

    var identity: Identity { return uuid }
}
