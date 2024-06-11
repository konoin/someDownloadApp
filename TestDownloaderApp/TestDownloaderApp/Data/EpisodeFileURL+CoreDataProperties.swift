//
//  EpisodeFileURL+CoreDataProperties.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 11.06.24.
//
//

import Foundation
import CoreData


extension EpisodeFileURL {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EpisodeFileURL> {
        return NSFetchRequest<EpisodeFileURL>(entityName: "EpisodeFileURL")
    }

    @NSManaged public var fileURL: String?
    @NSManaged public var history: History?

}

extension EpisodeFileURL : Identifiable {

}
