//
//  TestDownloaderAppApp.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 13.05.24.
//

import SwiftUI
import SwiftData

@main
struct TestDownloaderAppApp: App {

    var mainViewModel = MainViewModel()
    let persistentController = PersistenceController.shared
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistentController.container.viewContext)
                .modelContainer(persistentController.swiftaDataModelContainer!)
                .environmentObject(mainViewModel)
                .accessibilityIdentifier("MainView")
                .task {
                    try? await mainViewModel.fetchPodcast()
                }
        }
    }
    
//    init() {
//        let scheme = Schema([History.self, EpisodeFileURL.self])
//        let config = ModelConfiguration("History", schema: scheme)
//        )
//        do {
//            container = try ModelContainer {
//                for" "
//            }
//        }
//    }
}
