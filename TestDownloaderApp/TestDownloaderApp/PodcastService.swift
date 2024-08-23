//
//  PodcastService.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 23.08.24.
//

import Foundation
import SwiftData

struct HistoryService {
    var fetch: @Sendable () throws -> [History] = { [] }
}

@MainActor
extension HistoryService {
    static var context: Self {
        
        let dataBaseService = ServiceLocator.shared.resolveOrCreate(DataBaseService.value)
        
        return Self(
            fetch: {
                try fetch(dataBaseService: dataBaseService)
            })
        
        @Sendable func fetch(dataBaseService: DataBaseService) throws -> [History] {
            let context = try dataBaseService.context()
            let fetchDescriptor = FetchDescriptor<History>()
            return try context.fetch(fetchDescriptor)
        }
    }
}

