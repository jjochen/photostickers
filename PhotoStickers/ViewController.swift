//
//  ViewController.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 28/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreData
import RxCoreData
import Log

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        storeSticker()
    }

    func storeSticker() {

        guard let image = UIImage(named: "sticker") else {
            return
        }
        guard let data = UIImagePNGRepresentation(image) else {
            return
        }
        let uuid = UUID().uuidString

        guard let url = AppGroup.documentsURL?.appendingPathComponent("\(uuid).png") else {
            return
        }
        do {
            try data.write(to: url)
        } catch {
            Logger.shared.error(error)
            return
        }

        let sticker = Sticker(uuid: uuid, stickerPath: url.absoluteString, stickerDescription: "Pizza")

        let managedObject = NSEntityDescription.insertNewObject(forEntityName: Sticker.entityName, into: CoreDataStack.shared.viewContext)

        sticker.update(managedObject)
    }
}
