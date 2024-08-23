//
//  AppDelegate.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 23.07.24.
//

import UIKit
import UserNotifications

final class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var backgroundSessionCompletionHandler: (() -> Void)?
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        self.backgroundSessionCompletionHandler = completionHandler
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setupNotification()
        return true
    }
    
    private func setupNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (garanted, err) in
            if garanted {
                print("Permission garanted")
            } else {
                print("Permission no garanted")
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
    }
}
