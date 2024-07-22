//
//  EpisodeFileURL.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 18.07.24.
//
//

import Foundation
import SwiftData


@Model
class EpisodeFileURL {
    var fileURL: String
    @Relationship(inverse: \History.fileURL) var history: History?
    init(fileURL: String) {
        self.fileURL = fileURL
    }
    
}
