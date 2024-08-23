//
//  NotificationManagerProtocol.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 20.08.24.
//

import Foundation

protocol NotificationFacadeProtocol {
    func notificationPost(name: Notification.Name, object: Any?)
}
