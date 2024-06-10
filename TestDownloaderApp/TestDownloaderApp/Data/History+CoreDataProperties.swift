//
//  History+CoreDataProperties.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 10.06.24.
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
    @NSManaged public var file: FileUrl?

}

extension History : Identifiable {

}
