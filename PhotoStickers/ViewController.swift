//
//  ViewController.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 28/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        storeSticker()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func storeSticker() {
        
        guard let image = UIImage(named: "sticker") else {
            return
        }
        guard let data = UIImagePNGRepresentation(image) else {
            return
        }
        guard let filename = AppGroup.documentsURL?.appendingPathComponent("sticker.png") else
        {
            return
        }
        do {
            try data.write(to: filename)
        } catch {
            print(error)
            return
        }
    }
}

