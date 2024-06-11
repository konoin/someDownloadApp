//
//  History+CoreDataProperties.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 11.06.24.
//
//

import Foundation
import CoreData


extension History {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return NSFetchRequest<History>(entityName: "History")
    }

    @NSManaged public var date: Date?
    @NSManaged public var downloaded: Bool
    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var fileURL: EpisodeFileURL?

}

extension History : Identifiable {

}
