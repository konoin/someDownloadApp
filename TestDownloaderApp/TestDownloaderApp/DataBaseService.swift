//
//  DataBaseService.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 23.08.24.
//

import Foundation
import SwiftData

struct DataBaseService {
    var context: () throws -> ModelContext
}

extension DataBaseService {
    @MainActor
    static var value: Self {
        let appContext: ModelContext = {
            let container = SwiftDataModelConfiguration.shared.container
            print("new dataBaseService + ", container.configurations)
            let context = ModelContext(container)
            return context
        }()
        
        return Self(
            context: { appContext }
        )
    }
}
