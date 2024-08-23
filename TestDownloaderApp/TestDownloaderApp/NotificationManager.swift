//
//  NotificationManager.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 20.08.24.
//

import SwiftUI
import Combine

final class NotificationManager: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        subscribeToNotifications()
    }
    
    func subscribeToNotifications() {
        NotificationCenter.default.publisher(for: .downloadCompleted)
            .sink { [weak self] notification in
                if let episode = notification.object as? Episode {
                    self?.sendNotification(title: episode.title)
                }
            }
            .store(in: &cancellables)
    }
    
    func sendNotification(title: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "Episdoe: \(title) downloded"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func notificationPost(name: Notification.Name, object: Any?) {
        NotificationCenter.default.post(name: name, object: object)
    }
}
