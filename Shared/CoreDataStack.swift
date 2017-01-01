//
//  DataStore.swift
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 01/01/2017.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

import Foundation
import CoreData
import Log

final class CoreDataStack {

    static let shared = CoreDataStack()
    var errorHandler: (Error) -> Void = { _ in }

    lazy var persistentContainer: SharedPersistentContainer = {
        let container = SharedPersistentContainer(name: "PhotoStickers")
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                Logger.shared.error(error)
                self.errorHandler(error)
            }
        })
        return container
    }()

    lazy var viewContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()

    lazy var backgroundContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()

    func performForegroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.viewContext.perform {
            block(self.viewContext)
        }
    }

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.persistentContainer.performBackgroundTask(block)
    }

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = self.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                Logger.shared.error(error)
                self.errorHandler(error)
            }
        }
    }
}
