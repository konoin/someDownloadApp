//
//  ServiceLocator.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 31.07.24.
//

import Foundation

class ServiceLocator {
    static let shared = ServiceLocator()
    private var services: [String: Any] = [:]
    
    private init() {}
    
    func resolveOrCreate<T>(_ createDefault: @autoclosure () -> T) -> T {
        let key = "\(type(of: T.self))"
        if let service = services[key] as? T {
            return service
        } else {
            let defaultService = createDefault()
            services[key] = defaultService
            return defaultService
        }
    }
}
