//
//  NotificationViewModel.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 30.07.24.
//

import SwiftUI
import Combine

final class NotificationFacade: NotificationFacadeProtocol {
    
    private var notificationManager: NotificationManager
    
    init(notificationManager: NotificationManager = NotificationManager()) {
        self.notificationManager = notificationManager
    }
    
    func notificationPost(name: Notification.Name, object: Any?) {
        self.notificationManager.notificationPost(name: name, object: object)
    }
}

