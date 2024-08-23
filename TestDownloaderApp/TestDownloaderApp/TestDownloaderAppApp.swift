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
    
    init() {
        _ = ServiceLocator.shared.resolveOrCreate(NotificationFacade())
        _ = ServiceLocator.shared.resolveOrCreate(CustomFileManagerFacade())
        _ = ServiceLocator.shared.resolveOrCreate(DataBaseService.value)
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var contentViewViewModel = ContentViewViewModel()
//    let persistentController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(SwiftDataModelConfiguration.shared.container)
                .environmentObject(contentViewViewModel)
                .accessibilityIdentifier("MainView")
                .task {
                    try? await contentViewViewModel.fetchPodcast()
                }
        }
    }
}
