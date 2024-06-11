//
//  TestDownloaderAppApp.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 13.05.24.
//

import SwiftUI
import CoreData

@main
struct TestDownloaderAppApp: App {
    let persistentController = PersistenceController.shared
    let downloadFactory = ViewModelFactory()
    
    var body: some Scene {
        WindowGroup {
            ContentView(fetchViewModel: downloadFactory.makeFetchViewModel(), saveViewModel: downloadFactory.makeSaveViewModel())
                .environmentObject(downloadFactory)
                .environment(\.managedObjectContext, persistentController.container.viewContext)
        }
    }
}
