//
//  HistoryToHistoryMigrationPolicy.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 11.06.24.
//

import Foundation
import CoreData

final class HistoryToHistoryMigrationPolicy: NSEntityMigrationPolicy {
    
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)
        
        guard let dInstance = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstance]).first else { return }
        
        if let sourceFileURL = sInstance.value(forKey: "fileURL") as? String {
            guard let episodeFileURLEntityDescription = NSEntityDescription.entity(forEntityName: "EpisodeFileURL", in: manager.destinationContext) else { return }
            let newEpisodeFileURLInstance = NSManagedObject(entity: episodeFileURLEntityDescription, insertInto: manager.destinationContext)
            newEpisodeFileURLInstance.setValue(sourceFileURL, forKey: "fileURL")
            newEpisodeFileURLInstance.setValue(sourceFileURL, forKey: "history")
        }
    }
}
