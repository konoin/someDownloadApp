//
//  MigrationPolicy.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 11.06.24.
//

import Foundation
import CoreData

class HistoryToHistoryMigrationPolicy: NSEntityMigrationPolicy {

    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        
        // Создаем новую сущность History
        guard let historyEntityDescription = NSEntityDescription.entity(forEntityName: "History", in: manager.destinationContext) else {
            return
        }
        
        let newHistoryInstance = NSManagedObject(entity: historyEntityDescription, insertInto: manager.destinationContext)
        
        // Копируем атрибуты из старой версии в новую
        if let sourceDate = sInstance.value(forKey: "date") as? Date {
            newHistoryInstance.setValue(sourceDate, forKey: "date")
        }
        
        if let sourceDownloaded = sInstance.value(forKey: "downloaded") as? Bool {
            newHistoryInstance.setValue(sourceDownloaded, forKey: "downloaded")
        }
        
        if let sourceId = sInstance.value(forKey: "id") as? Int64 {
            newHistoryInstance.setValue(sourceId, forKey: "id")
        }
        
        if let sourceTitle = sInstance.value(forKey: "title") as? String {
            newHistoryInstance.setValue(sourceTitle, forKey: "title")
        }

        // Создаем новую сущность EpisodeFileURL и связываем с History
        if let sourceFileURL = sInstance.value(forKey: "fileURL") as? String {
            guard let episodeFileURLEntityDescription = NSEntityDescription.entity(forEntityName: "EpisodeFileURL", in: manager.destinationContext) else {
                return
            }
            
            let newEpisodeFileURLInstance = NSManagedObject(entity: episodeFileURLEntityDescription, insertInto: manager.destinationContext)
            newEpisodeFileURLInstance.setValue(sourceFileURL, forKey: "fileURL")
            
            // Устанавливаем связь между History и EpisodeFileURL
            newEpisodeFileURLInstance.setValue(newHistoryInstance, forKey: "history")
        }

        // Устанавливаем связь между старым и новым объектом
        manager.associate(sourceInstance: sInstance, withDestinationInstance: newHistoryInstance, for: mapping)
    }
}
