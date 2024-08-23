//
//  SwiftDataModelConfiguration.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 23.08.24.
//

import SwiftData

public class SwiftDataModelConfiguration {
    public static let shared = SwiftDataModelConfiguration(isSortedMemoryOnly: false, autosaveEnable: false)
    
    private var isStoredInMemoryOnly: Bool
    private var autosaveEnabled: Bool
    
    private init(isSortedMemoryOnly: Bool, autosaveEnable: Bool) {
        self.isStoredInMemoryOnly = isSortedMemoryOnly
        self.autosaveEnabled = autosaveEnable
    }
    
    @MainActor
    public lazy var container: ModelContainer = {
        // Define schema and configuration
        let schema = Schema(
            [
                History.self,
                EpisodeFileURL.self
            ]
        )
        let configuration = ModelConfiguration(isStoredInMemoryOnly: isStoredInMemoryOnly)

        let container = try! ModelContainer(for: schema, configurations: [configuration])
        container.mainContext.autosaveEnabled = autosaveEnabled
        return container
    }()
}
