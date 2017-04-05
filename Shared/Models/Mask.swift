//
//  MaskType.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 10/03/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import UIKit

enum Mask: Int {
    case rectangle = 1
    case circle = 2
    case star = 3
}

extension Mask {

    func maskPath(in rect: CGRect) -> UIBezierPath {
        return maskPath(in: rect, maskRect: rect)
    }

    func maskPath(in rect: CGRect, maskRect: CGRect) -> UIBezierPath {
        let maskPath = UIBezierPath(rect: rect)
        maskPath.usesEvenOddFillRule = true
        let path = self.path(in: maskRect)
        maskPath.append(path)
        return maskPath
    }

    func path(in rect: CGRect) -> UIBezierPath {
        switch self {
        case .rectangle:
            return rectanglePath(in: rect)
        case .circle:
            return circlePath(in: rect)
        case .star:
            return starPath(in: rect)
        }
    }
}

extension Mask {
    fileprivate func rectanglePath(in rect: CGRect) -> UIBezierPath {
        let minSideLength = min(rect.width, rect.height)
        return UIBezierPath(roundedRect: rect, cornerRadius: minSideLength * 0.15)
    }

    fileprivate func circlePath(in rect: CGRect) -> UIBezierPath {
        return UIBezierPath(ovalIn: rect)
    }

    fileprivate func starPath(in rect: CGRect) -> UIBezierPath {

        let pointsOnStar = 5

        let path = UIBezierPath()

        let minSide = min(rect.width, rect.height)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var angle: CGFloat = -CGFloat(Double.pi / 2.0)
        let angleIncrement = CGFloat(Double.pi * 2.0 / Double(pointsOnStar))
        let outerRadius = minSide / 2.0
        let innerRadius = minSide / 4.0

        var firstPoint = true

        for _ in 1 ... pointsOnStar {

            let point = CGPoint(angle: angle, radius: outerRadius, offset: center)
            let nextPoint = CGPoint(angle: angle + angleIncrement, radius: outerRadius, offset: center)
            let midPoint = CGPoint(angle: angle + angleIncrement / 2.0, radius: innerRadius, offset: center)

            if firstPoint {
                firstPoint = false
                path.move(to: point)
            }

            path.addLine(to: midPoint)
            path.addLine(to: nextPoint)

            angle += angleIncrement
        }

        path.close()

        return path
    }
}

extension CGPoint {
    init(angle: CGFloat, radius: CGFloat, offset: CGPoint) {
        self.init(x: radius * cos(angle) + offset.x, y: radius * sin(angle) + offset.y)
    }
}
