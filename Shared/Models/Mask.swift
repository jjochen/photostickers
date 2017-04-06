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
    case multiStar = 4
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
            return starPath(in: rect, flipped: flipped)
        case .multiStar:
            return multiStarPath(in: rect, flipped: flipped)
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

    fileprivate func starPath(in rect: CGRect, flipped: Bool) -> UIBezierPath {

        let originalRect = CGRect(x: 0, y: 0, width: 44, height: 44)

        let starPath = UIBezierPath()
        if !flipped {
            starPath.move(to: CGPoint(x: 22, y: 1))
            starPath.addLine(to: CGPoint(x: 30.11, y: 12.84))
            starPath.addLine(to: CGPoint(x: 43.87, y: 16.89))
            starPath.addLine(to: CGPoint(x: 35.12, y: 28.26))
            starPath.addLine(to: CGPoint(x: 35.52, y: 42.61))
            starPath.addLine(to: CGPoint(x: 22, y: 37.8))
            starPath.addLine(to: CGPoint(x: 8.48, y: 42.61))
            starPath.addLine(to: CGPoint(x: 8.88, y: 28.26))
            starPath.addLine(to: CGPoint(x: 0.13, y: 16.89))
            starPath.addLine(to: CGPoint(x: 13.89, y: 12.84))
            starPath.close()
        } else {
            starPath.move(to: CGPoint(x: 22, y: 43))
            starPath.addLine(to: CGPoint(x: 30.11, y: 31.16))
            starPath.addLine(to: CGPoint(x: 43.87, y: 27.11))
            starPath.addLine(to: CGPoint(x: 35.12, y: 15.74))
            starPath.addLine(to: CGPoint(x: 35.52, y: 1.39))
            starPath.addLine(to: CGPoint(x: 22, y: 6.2))
            starPath.addLine(to: CGPoint(x: 8.48, y: 1.39))
            starPath.addLine(to: CGPoint(x: 8.88, y: 15.74))
            starPath.addLine(to: CGPoint(x: 0.13, y: 27.11))
            starPath.addLine(to: CGPoint(x: 13.89, y: 31.16))
            starPath.close()
        }

        let ratio = min(rect.width / originalRect.width, rect.height / originalRect.height)
        starPath.apply(CGAffineTransform(scaleX: ratio, y: ratio))
        starPath.apply(CGAffineTransform(translationX: rect.minX, y: rect.minY))

        starPath.lineCapStyle = .round
        starPath.lineJoinStyle = .round
        return starPath
    }

    fileprivate func multiStarPath(in rect: CGRect, flipped: Bool) -> UIBezierPath {

        let originalRect = CGRect(x: 0, y: 0, width: 44, height: 44)

        let starPath = UIBezierPath()
        if !flipped {
            starPath.move(to: CGPoint(x: 22, y: 0))
            starPath.addLine(to: CGPoint(x: 23.95, y: 3.49))
            starPath.addLine(to: CGPoint(x: 26.57, y: 0.48))
            starPath.addLine(to: CGPoint(x: 27.75, y: 4.3))
            starPath.addLine(to: CGPoint(x: 30.95, y: 1.9))
            starPath.addLine(to: CGPoint(x: 31.3, y: 5.88))
            starPath.addLine(to: CGPoint(x: 34.93, y: 4.2))
            starPath.addLine(to: CGPoint(x: 34.45, y: 8.17))
            starPath.addLine(to: CGPoint(x: 38.35, y: 7.28))
            starPath.addLine(to: CGPoint(x: 37.06, y: 11.06))
            starPath.addLine(to: CGPoint(x: 41.05, y: 11))
            starPath.addLine(to: CGPoint(x: 39, y: 14.43))
            starPath.addLine(to: CGPoint(x: 42.92, y: 15.2))
            starPath.addLine(to: CGPoint(x: 40.2, y: 18.13))
            starPath.addLine(to: CGPoint(x: 43.88, y: 19.7))
            starPath.addLine(to: CGPoint(x: 40.61, y: 22))
            starPath.addLine(to: CGPoint(x: 43.88, y: 24.3))
            starPath.addLine(to: CGPoint(x: 40.2, y: 25.87))
            starPath.addLine(to: CGPoint(x: 42.92, y: 28.8))
            starPath.addLine(to: CGPoint(x: 39, y: 29.57))
            starPath.addLine(to: CGPoint(x: 41.05, y: 33))
            starPath.addLine(to: CGPoint(x: 37.06, y: 32.94))
            starPath.addLine(to: CGPoint(x: 38.35, y: 36.72))
            starPath.addLine(to: CGPoint(x: 34.45, y: 35.83))
            starPath.addLine(to: CGPoint(x: 34.93, y: 39.8))
            starPath.addLine(to: CGPoint(x: 31.3, y: 38.12))
            starPath.addLine(to: CGPoint(x: 30.95, y: 42.1))
            starPath.addLine(to: CGPoint(x: 27.75, y: 39.7))
            starPath.addLine(to: CGPoint(x: 26.57, y: 43.52))
            starPath.addLine(to: CGPoint(x: 23.95, y: 40.51))
            starPath.addLine(to: CGPoint(x: 22, y: 44))
            starPath.addLine(to: CGPoint(x: 20.05, y: 40.51))
            starPath.addLine(to: CGPoint(x: 17.43, y: 43.52))
            starPath.addLine(to: CGPoint(x: 16.25, y: 39.7))
            starPath.addLine(to: CGPoint(x: 13.05, y: 42.1))
            starPath.addLine(to: CGPoint(x: 12.7, y: 38.12))
            starPath.addLine(to: CGPoint(x: 9.07, y: 39.8))
            starPath.addLine(to: CGPoint(x: 9.55, y: 35.83))
            starPath.addLine(to: CGPoint(x: 5.65, y: 36.72))
            starPath.addLine(to: CGPoint(x: 6.94, y: 32.94))
            starPath.addLine(to: CGPoint(x: 2.95, y: 33))
            starPath.addLine(to: CGPoint(x: 5, y: 29.57))
            starPath.addLine(to: CGPoint(x: 1.08, y: 28.8))
            starPath.addLine(to: CGPoint(x: 3.8, y: 25.87))
            starPath.addLine(to: CGPoint(x: 0.12, y: 24.3))
            starPath.addLine(to: CGPoint(x: 3.39, y: 22))
            starPath.addLine(to: CGPoint(x: 0.12, y: 19.7))
            starPath.addLine(to: CGPoint(x: 3.8, y: 18.13))
            starPath.addLine(to: CGPoint(x: 1.08, y: 15.2))
            starPath.addLine(to: CGPoint(x: 5, y: 14.43))
            starPath.addLine(to: CGPoint(x: 2.95, y: 11))
            starPath.addLine(to: CGPoint(x: 6.94, y: 11.06))
            starPath.addLine(to: CGPoint(x: 5.65, y: 7.28))
            starPath.addLine(to: CGPoint(x: 9.55, y: 8.17))
            starPath.addLine(to: CGPoint(x: 9.07, y: 4.2))
            starPath.addLine(to: CGPoint(x: 12.7, y: 5.88))
            starPath.addLine(to: CGPoint(x: 13.05, y: 1.9))
            starPath.addLine(to: CGPoint(x: 16.25, y: 4.3))
            starPath.addLine(to: CGPoint(x: 17.43, y: 0.48))
            starPath.addLine(to: CGPoint(x: 20.05, y: 3.49))
            starPath.close()
        } else {
            starPath.move(to: CGPoint(x: 22, y: 44))
            starPath.addLine(to: CGPoint(x: 23.95, y: 40.51))
            starPath.addLine(to: CGPoint(x: 26.57, y: 43.52))
            starPath.addLine(to: CGPoint(x: 27.75, y: 39.7))
            starPath.addLine(to: CGPoint(x: 30.95, y: 42.1))
            starPath.addLine(to: CGPoint(x: 31.3, y: 38.12))
            starPath.addLine(to: CGPoint(x: 34.93, y: 39.8))
            starPath.addLine(to: CGPoint(x: 34.45, y: 35.83))
            starPath.addLine(to: CGPoint(x: 38.35, y: 36.72))
            starPath.addLine(to: CGPoint(x: 37.06, y: 32.94))
            starPath.addLine(to: CGPoint(x: 41.05, y: 33))
            starPath.addLine(to: CGPoint(x: 39, y: 29.57))
            starPath.addLine(to: CGPoint(x: 42.92, y: 28.8))
            starPath.addLine(to: CGPoint(x: 40.2, y: 25.87))
            starPath.addLine(to: CGPoint(x: 43.88, y: 24.3))
            starPath.addLine(to: CGPoint(x: 40.61, y: 22))
            starPath.addLine(to: CGPoint(x: 43.88, y: 19.7))
            starPath.addLine(to: CGPoint(x: 40.2, y: 18.13))
            starPath.addLine(to: CGPoint(x: 42.92, y: 15.2))
            starPath.addLine(to: CGPoint(x: 39, y: 14.43))
            starPath.addLine(to: CGPoint(x: 41.05, y: 11))
            starPath.addLine(to: CGPoint(x: 37.06, y: 11.06))
            starPath.addLine(to: CGPoint(x: 38.35, y: 7.28))
            starPath.addLine(to: CGPoint(x: 34.45, y: 8.17))
            starPath.addLine(to: CGPoint(x: 34.93, y: 4.2))
            starPath.addLine(to: CGPoint(x: 31.3, y: 5.88))
            starPath.addLine(to: CGPoint(x: 30.95, y: 1.9))
            starPath.addLine(to: CGPoint(x: 27.75, y: 4.3))
            starPath.addLine(to: CGPoint(x: 26.57, y: 0.48))
            starPath.addLine(to: CGPoint(x: 23.95, y: 3.49))
            starPath.addLine(to: CGPoint(x: 22, y: 0))
            starPath.addLine(to: CGPoint(x: 20.05, y: 3.49))
            starPath.addLine(to: CGPoint(x: 17.43, y: 0.48))
            starPath.addLine(to: CGPoint(x: 16.25, y: 4.3))
            starPath.addLine(to: CGPoint(x: 13.05, y: 1.9))
            starPath.addLine(to: CGPoint(x: 12.7, y: 5.88))
            starPath.addLine(to: CGPoint(x: 9.07, y: 4.2))
            starPath.addLine(to: CGPoint(x: 9.55, y: 8.17))
            starPath.addLine(to: CGPoint(x: 5.65, y: 7.28))
            starPath.addLine(to: CGPoint(x: 6.94, y: 11.06))
            starPath.addLine(to: CGPoint(x: 2.95, y: 11))
            starPath.addLine(to: CGPoint(x: 5, y: 14.43))
            starPath.addLine(to: CGPoint(x: 1.08, y: 15.2))
            starPath.addLine(to: CGPoint(x: 3.8, y: 18.13))
            starPath.addLine(to: CGPoint(x: 0.12, y: 19.7))
            starPath.addLine(to: CGPoint(x: 3.39, y: 22))
            starPath.addLine(to: CGPoint(x: 0.12, y: 24.3))
            starPath.addLine(to: CGPoint(x: 3.8, y: 25.87))
            starPath.addLine(to: CGPoint(x: 1.08, y: 28.8))
            starPath.addLine(to: CGPoint(x: 5, y: 29.57))
            starPath.addLine(to: CGPoint(x: 2.95, y: 33))
            starPath.addLine(to: CGPoint(x: 6.94, y: 32.94))
            starPath.addLine(to: CGPoint(x: 5.65, y: 36.72))
            starPath.addLine(to: CGPoint(x: 9.55, y: 35.83))
            starPath.addLine(to: CGPoint(x: 9.07, y: 39.8))
            starPath.addLine(to: CGPoint(x: 12.7, y: 38.12))
            starPath.addLine(to: CGPoint(x: 13.05, y: 42.1))
            starPath.addLine(to: CGPoint(x: 16.25, y: 39.7))
            starPath.addLine(to: CGPoint(x: 17.43, y: 43.52))
            starPath.addLine(to: CGPoint(x: 20.05, y: 40.51))
            starPath.close()
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
