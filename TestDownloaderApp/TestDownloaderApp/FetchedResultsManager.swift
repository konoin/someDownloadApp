//
//  FetchedResultsManager.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 7.06.24.
//

import Foundation
import CoreData

class FetchedResultsManager: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    private let fetchController: NSFetchedResultsController<History>

    init(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<History> = History.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \History.title, ascending: true)]
        fetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        super.init()
        fetchController.delegate = self
        performFetch()
    }

    var fetchedObjects: [History] {
        fetchController.fetchedObjects ?? []
    }

    func performFetch() {
        do {
            try fetchController.performFetch()
        } catch {
            print("Fetch request failed: \(error)")
        }
    }
}
