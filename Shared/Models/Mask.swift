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

    func maskPath(in rect: CGRect, maskRect: CGRect, flipped: Bool = false) -> UIBezierPath {
        let maskPath = UIBezierPath(rect: rect)
        maskPath.usesEvenOddFillRule = true
        let path = self.path(in: maskRect, flipped: flipped)
        maskPath.append(path)
        return maskPath
    }

    func path(in rect: CGRect, flipped: Bool = false) -> UIBezierPath {
        switch self {
        case .rectangle:
            return rectanglePath(in: rect)
        case .circle:
            return circlePath(in: rect)
        case .star:
            return newStarPath(in: rect, flipped: flipped)
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

    fileprivate func newStarPath(in rect: CGRect, flipped: Bool) -> UIBezierPath {

        let originalRect = CGRect(x: 0, y: 0, width: 44, height: 44)

        let starPath = UIBezierPath()
        if !flipped {
            starPath.move(to: CGPoint(x: 22, y: 2))
            starPath.addLine(to: CGPoint(x: 29.76, y: 13.32))
            starPath.addLine(to: CGPoint(x: 42.92, y: 17.2))
            starPath.addLine(to: CGPoint(x: 34.55, y: 28.08))
            starPath.addLine(to: CGPoint(x: 34.93, y: 41.8))
            starPath.addLine(to: CGPoint(x: 22, y: 37.2))
            starPath.addLine(to: CGPoint(x: 9.07, y: 41.8))
            starPath.addLine(to: CGPoint(x: 9.45, y: 28.08))
            starPath.addLine(to: CGPoint(x: 1.08, y: 17.2))
            starPath.addLine(to: CGPoint(x: 14.24, y: 13.32))
            starPath.close()
        } else {
            starPath.move(to: CGPoint(x: 22, y: -2))
            starPath.addLine(to: CGPoint(x: 29.76, y: -13.32))
            starPath.addLine(to: CGPoint(x: 42.92, y: -17.2))
            starPath.addLine(to: CGPoint(x: 34.55, y: -28.08))
            starPath.addLine(to: CGPoint(x: 34.93, y: -41.8))
            starPath.addLine(to: CGPoint(x: 22, y: -37.2))
            starPath.addLine(to: CGPoint(x: 9.07, y: -41.8))
            starPath.addLine(to: CGPoint(x: 9.45, y: -28.08))
            starPath.addLine(to: CGPoint(x: 1.08, y: -17.2))
            starPath.addLine(to: CGPoint(x: 14.24, y: -13.32))
            starPath.close()
            starPath.apply(CGAffineTransform(translationX: 0, y: originalRect.height))
        }

        let ratio = min(rect.width / originalRect.width, rect.height / originalRect.height)
        starPath.apply(CGAffineTransform(scaleX: ratio, y: ratio))
        starPath.apply(CGAffineTransform(translationX: rect.minX, y: rect.minY))

        starPath.lineCapStyle = .round
        starPath.lineJoinStyle = .round
        return starPath
    }
}

extension CGPoint {
    init(angle: CGFloat, radius: CGFloat, offset: CGPoint) {
        self.init(x: radius * cos(angle) + offset.x, y: radius * sin(angle) + offset.y)
    }
}
