//
//  TestViewController.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 21/03/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var effectView: UIVisualEffectView!

    var maskView: UIView = {
        let maskView = UIView()
        maskView.backgroundColor = UIColor.black
        return maskView
    }()

    var maskLayer: CAShapeLayer = {
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = kCAFillRuleEvenOdd
        return maskLayer
    }()

    var mask: Mask = .circle

    @IBAction func maskWithStar(_ sender: Any) {
        self.mask = .rectangle
        self.updateMask()
    }

    override func viewDidLoad() {
        debugPrint("Running...")

        super.viewDidLoad()

        // Lets load an image first, so blur looks cool
        let url = URL(string: "https://static.pexels.com/photos/168066/pexels-photo-168066-large.jpeg")

        URLSession.shared.dataTask(with: url!) {
            data, response, error in

            if error != nil {
                print(error!)
                return
            }

            DispatchQueue.main.async(execute: {
                self.imageView.image = UIImage(data: data!)
                self.updateMask()
            })

        }.resume()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        self.updateMask()
    }

    func updateMask() {

        self.maskView.frame = self.view.bounds
        let parentBounds = self.maskView.bounds
        let size: CGFloat = 200.0
        let offset = (min(parentBounds.width, parentBounds.height) - size) / 2
        let maskRect = CGRect(x: offset, y: offset, width: size, height: size)
        let path = self.mask.maskPath(in: parentBounds, maskRect: maskRect)

        self.maskLayer.path = path.cgPath
        self.maskView.layer.mask = self.maskLayer
        self.effectView.mask = self.maskView
    }
}
