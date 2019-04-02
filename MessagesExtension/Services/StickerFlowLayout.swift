//
//  StickerFlowLayout.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 09.04.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit

struct StickerFlowLayout {
    fileprivate static func minimumItemWidth(in _: CGRect) -> CGFloat {
        return 90
    }

    static func sectionInsets(in _: CGRect) -> UIEdgeInsets {
        let inset = CGFloat(12)
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }

    static func minimumInterItemSpacing(in _: CGRect) -> CGFloat {
        return 10
    }

    static func minimumLineSpacing(in bounds: CGRect) -> CGFloat {
        return minimumInterItemSpacing(in: bounds)
    }

    static func itemSize(in bounds: CGRect) -> CGSize {
        let sectionInsets = self.sectionInsets(in: bounds)
        let minimumInterItemSpacing = self.minimumInterItemSpacing(in: bounds)
        let minimumItemWidth = self.minimumItemWidth(in: bounds)

        let numberOfItems = floor((bounds.width - sectionInsets.left - sectionInsets.right + minimumInterItemSpacing) / (minimumItemWidth + minimumInterItemSpacing))

        let maxItemWidth = (bounds.size.width - sectionInsets.left - sectionInsets.right - (numberOfItems - 1) * minimumInterItemSpacing) / numberOfItems

        let sideLength = floor(maxItemWidth)
        return CGSize(width: sideLength, height: sideLength)
    }
}
