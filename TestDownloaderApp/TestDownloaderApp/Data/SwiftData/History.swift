//
//  History.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 18.07.24.
//
//

import Foundation
import SwiftData

@Model 
class History {
    @Attribute(.unique) var id: Int64
    var title: String
    var date: Date
    var downloaded: Bool
    @Attribute(.unique) var fileURL: EpisodeFileURL?
    
    init(date: Date, downloaded: Bool, id: Int64, title: String, fileURL: EpisodeFileURL? = nil) {
        self.date = date
        self.downloaded = downloaded
        self.id = id
        self.title = title
        self.fileURL = fileURL
    }
    
}
