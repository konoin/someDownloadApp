//
//  History+CoreDataProperties.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 31.05.24.
//
//

import Foundation
import CoreData


extension History {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return NSFetchRequest<History>(entityName: "History")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: NSNumber?
    @NSManaged public var title: String?
    @NSManaged public var downloaded: Bool
    @NSManaged public var finder: Bool

}

extension History : Identifiable {

}
