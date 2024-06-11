//
//  PersistentContoller.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 4.06.24.
//

import CoreData

class PersistenceController: NSObject {
    
    static let shared = PersistenceController()
    let container: NSPersistentContainer = NSPersistentContainer(name: "DownloadHistory")
    
    override init() {
        super.init()
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(path: "TestDownloaderApp.sqlite")
           
           // Change URL to allow for compatibility with older version in Swift
           let description = NSPersistentStoreDescription(url: paths)
           container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, _ in
            
        }
    }
    
    func saveChanges() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Could not save changes to Core Data.", error.localizedDescription)
            }
        }
    }
    
    func create(title: String, id: Int64, downloaded: Bool, date: Date, fileURL: String) {
        // create a NSManagedObject, will be saved to DB later
        let entity = History(context: container.viewContext)
        let fileUrl = EpisodeFileURL(context: container.viewContext)
        // attach value to the entity’s attributes
        entity.title = title
        entity.id = id
        entity.downloaded = downloaded
        entity.date = date
        fileUrl.fileURL = fileURL
        entity.fileURL = fileUrl
        // save changes to DB
        saveChanges()
    }
    
    func read(predicateFormat: String? = nil, fetchLimit: Int? = nil) -> [History] {
        // create a temp array to save fetched notes
        var results: [History] = []
        // initialize the fetch request
        let request = NSFetchRequest<History>(entityName: "History")

        // define filter and/or limit if needed
        if predicateFormat != nil {
            request.predicate = NSPredicate(format: predicateFormat!)
        }
        if fetchLimit != nil {
            request.fetchLimit = fetchLimit!
        }

        // fetch with the request
        do {
            results = try container.viewContext.fetch(request)
        } catch {
            print("Could not fetch notes from Core Data.")
        }

        // return results
        return results
    }
    
    func update(entity: History, title: String? = nil, downloaded: Bool? = nil, id: Int64? = nil, date: Date? = nil, fileURL: String? = nil) {
        // create a temp var to tell if an attribute is changed
        var hasChanges: Bool = false

        // update the attributes if a value is passed into the function
        if title != nil {
            entity.title = title!
            hasChanges = true
        }
        
        if downloaded != nil {
            entity.downloaded = downloaded!
            hasChanges = true
        }
        
        if id != nil {
            entity.id = id!
            hasChanges = true
        }
        
        if date != nil {
            entity.date = date!
            hasChanges = true
        }
        
        if fileURL != nil {
            entity.fileURL?.fileURL = fileURL!
//            entity.fileURL = episodeFileURL
            hasChanges = true
        }

        // save changes if any
        if hasChanges {
            saveChanges()
        }
    }

    func delete(_ entity: History) {
        container.viewContext.delete(entity)
        saveChanges()
    }
}

