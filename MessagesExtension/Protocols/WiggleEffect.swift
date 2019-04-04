//
//  WiggleEffect.swift
//  MessagesExtension
//
//  Created by Jochen on 04.04.19.
//  Copyright © 2019 Jochen Pfeiffer. All rights reserved.
//

import UIKit

protocol WiggleEffect {
    func startWiggle()
    func stopWiggle()
}

extension WiggleEffect where Self: UIView {
    func startWiggle() {
        let wiggleBounceY = 1.0
        let wiggleBounceDuration = 0.18
        let wiggleBounceDurationVariance = 0.025

        let wiggleRotateAngle = 0.02
        let wiggleRotateDuration = 0.14
        let wiggleRotateDurationVariance = 0.025

        guard !hasWiggleAnimation else {
            return
        }

        // Create rotation animation
        let rotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.values = [-wiggleRotateAngle, wiggleRotateAngle]
        rotationAnimation.autoreverses = true
        rotationAnimation.duration = randomize(interval: wiggleRotateDuration, withVariance: wiggleRotateDurationVariance)
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.isRemovedOnCompletion = false

        // Create bounce animation
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        bounceAnimation.values = [wiggleBounceY, 0]
        bounceAnimation.autoreverses = true
        bounceAnimation.duration = randomize(interval: wiggleBounceDuration, withVariance: wiggleBounceDurationVariance)
        bounceAnimation.repeatCount = .infinity
        bounceAnimation.isRemovedOnCompletion = false

        // Apply animations to view
        UIView.animate(withDuration: 0) {
            self.layer.add(rotationAnimation, forKey: AnimationKey.Rotation)
            self.layer.add(bounceAnimation, forKey: AnimationKey.Bounce)
            self.transform = .identity
        }
    }

    func stopWiggle() {
        layer.removeAnimation(forKey: AnimationKey.Rotation)
        layer.removeAnimation(forKey: AnimationKey.Bounce)
    }

    // Utility

    private var hasWiggleAnimation: Bool {
        guard let keys = layer.animationKeys() else {
            return false
        }

        return keys.contains(AnimationKey.Bounce) || keys.contains(AnimationKey.Rotation)
    }

    private func randomize(interval: TimeInterval, withVariance variance: Double) -> Double {
        let random = (Double(arc4random_uniform(1000)) - 500.0) / 500.0
        return interval + variance * random
    }
}

private struct AnimationKey {
    static let Rotation = "wiggle.rotation"
    static let Bounce = "wiggle.bounce"
}
