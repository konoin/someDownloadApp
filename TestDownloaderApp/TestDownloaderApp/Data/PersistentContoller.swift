//
//  PersistentContoller.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 4.06.24.
//

import CoreData

class PersistenceController: NSObject {
    
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    
    override init() {
        container = NSPersistentContainer(name: "DownloadHistory")
        super.init()
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("TestDownloaderApp.sqlite")
        let description = NSPersistentStoreDescription(url: paths)
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            } else {
                print("Persistent store loaded successfully: \(storeDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func saveChanges() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
                print("Changes saved successfully.")
            } catch {
                print("Could not save changes to Core Data.", error.localizedDescription)
            }
        }
    }
    
    func create(title: String, id: Int64, downloaded: Bool, date: Date, fileURL: String) {
        let context = container.viewContext
        let entity = History(context: context)
        let fileUrl = EpisodeFileURL(context: context)

        entity.title = title
        entity.id = id
        entity.downloaded = downloaded
        entity.date = date
        fileUrl.fileURL = fileURL
        entity.fileURL = fileUrl
        
        saveChanges()
    }
    
    func read(predicateFormat: String? = nil, fetchLimit: Int? = nil) -> [History] {
        var results: [History] = []
        let request = NSFetchRequest<History>(entityName: "History")
        
        if let predicateFormat = predicateFormat {
            request.predicate = NSPredicate(format: predicateFormat)
        }
        if let fetchLimit = fetchLimit {
            request.fetchLimit = fetchLimit
        }

        do {
            results = try container.viewContext.fetch(request)
        } catch {
            print("Could not fetch notes from Core Data.")
        }

        return results
    }
    
    func update(entity: History, title: String? = nil, downloaded: Bool? = nil, id: Int64? = nil, date: Date? = nil, fileURL: String? = nil) {
        var hasChanges = false

        if let title = title {
            entity.title = title
            hasChanges = true
        }
        
        if let downloaded = downloaded {
            entity.downloaded = downloaded
            hasChanges = true
        }
        
        if let id = id {
            entity.id = id
            hasChanges = true
        }
        
        if let date = date {
            entity.date = date
            hasChanges = true
        }
        
        if let fileURL = fileURL {
            entity.fileURL?.fileURL = fileURL
            hasChanges = true
        }

        if hasChanges {
            saveChanges()
        }
    }

    func delete(_ entity: History) {
        container.viewContext.delete(entity)
        saveChanges()
    }
}
