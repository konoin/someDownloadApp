//
//  PersistentContoller.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 4.06.24.
//

import CoreData
import SwiftData

//class PersistenceController: NSObject {
//    
//    static let shared = PersistenceController()
//    let container: NSPersistentContainer
//    
//    var swiftaDataModelContainer: ModelContainer?
//    
//    init(inMemory: Bool = true) {
//        container = NSPersistentContainer(name: "DownloadHistory")
//        super.init()
//        
//        if inMemory {
//            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("TestDownloaderApp.sqlite")
//            let description = NSPersistentStoreDescription(url: paths)
//            container.persistentStoreDescriptions = [description]
//        }
//        
//        if let description = container.persistentStoreDescriptions.first {
//            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
//        }
//        
//        container.loadPersistentStores { [weak self]storeDescription, error in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            } else {
//                if let url = storeDescription.url {
//                    do {
//                        let config = ModelConfiguration(url: url)
//                        let scheme = Schema([History.self, EpisodeFileURL.self])
//                        
//                        self?.swiftaDataModelContainer = try ModelContainer(for: scheme, configurations: config)
//                    } catch {
//                        let nsError = error as NSError
//                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//                        
//                    }
//                }
//            }
//        }
//        container.viewContext.automaticallyMergesChangesFromParent = true
//        print("first container + ", swiftaDataModelContainer?.configurations)
//    }
//
//    func createSwiftData(title: String, id: Int64, downloaded: Bool, date: Date, fileURL: String) {
//        guard let container = swiftaDataModelContainer else { return }
//        
//        let episodeURL = EpisodeFileURL(fileURL: fileURL)
//        let newEpisode = History(date: date, downloaded: downloaded, id: id, title: title, fileURL: episodeURL)
//        
//        let context = ModelContext(container)
//        
//        context.insert(newEpisode)
//    }
//    
//    func updateSwiftData(entity: History, title: String? = nil, downloaded: Bool? = nil, fileURL: String? = nil) {
//        guard let container = swiftaDataModelContainer else { return }
//        var hasChanges = false
//        
//        if let title = title {
//            entity.title = title
//            hasChanges = true
//        }
//        
//        if let downloaded = downloaded {
//            entity.downloaded = downloaded
//            hasChanges = true
//        }
//        
//        if let fileURL = fileURL {
//            entity.fileURL?.fileURL = fileURL
//            hasChanges = true
//        }
//        
//        let context = ModelContext(container)
//        
//        if hasChanges {
//            context.insert(entity)
//        }
//    }
//}
