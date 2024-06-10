//
//  FileUrl+CoreDataProperties.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 10.06.24.
//
//

import Foundation
import CoreData


extension FileUrl {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FileUrl> {
        return NSFetchRequest<FileUrl>(entityName: "FileUrl")
    }

    @NSManaged public var fileLocation: String?
    @NSManaged public var historyItem: History?

}

extension FileUrl : Identifiable {

}
