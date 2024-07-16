//
//  TestDownloaderAppApp.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 13.05.24.
//

import SwiftUI

@main
struct TestDownloaderAppApp: App {
    var mainViewModel = MainViewModel()
    let persistentController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistentController.container.viewContext)
                .environmentObject(mainViewModel)
                .accessibilityIdentifier("MainView")
                .task {
                    try? await mainViewModel.fetchPodcast()
                }
        }
    }
}
