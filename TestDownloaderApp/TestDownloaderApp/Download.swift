//
//  Download.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 15.05.24.
//

import Foundation
import UIKit

final class Download: NSObject {
    
    private var continuation: AsyncStream<Event>.Continuation?
    var task: URLSessionDownloadTask?
    
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var fileManager: CustomFileManagerFacade?
    private var previousBytesWritten: Int64 = 0
    private var totalBytesWritten: Int64 = 0
    private var startTime: Date?
    
    var isDownloading: Bool {
        task?.state == .running
    }
    
    var events: AsyncStream<Event> {
        AsyncStream { continuation in
            self.continuation = continuation
            self.task?.resume()
            continuation.onTermination = { @Sendable [weak self] _ in
                self?.task?.cancel()
            }
        }
    }
    
    init(url: URL) {
        self.fileManager = ServiceLocator.shared.resolveOrCreate(CustomFileManagerFacade())
        super.init()
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.background.test.\(UUID().uuidString)")
        configuration.isDiscretionary = true
        configuration.sessionSendsLaunchEvents = true
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        let urlRequest = URLRequest(url: url)
        self.task = session.downloadTask(with: urlRequest)
        self.task?.resume()
        
    }
    
    func pause() {
        self.task?.suspend()
    }
    
    func resume() {
        self.task?.resume()
    }
}

extension Download {
    enum Event {
        case progress(currentBytes: Int64, totalBytes: Int64, speed: Double)
        case success(url: URL, downloadTask: URLSessionDownloadTask)
    }
}

extension Download: URLSessionDelegate, URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let fileManager = fileManager else { return }
        do {
            
        let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            let destinationURL = documentsDirectory.appendingPathComponent(location.lastPathComponent)
            
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            
            try fileManager.moveItem(at: location, to: destinationURL)
            
            continuation?.yield(.success(url: destinationURL, downloadTask: downloadTask))
            
        } catch {
            print("Error while moving file: \(error.localizedDescription)")
        }
        continuation?.finish()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let now = Date()
        if let startTime = startTime {
            let timeInterval = now.timeIntervalSince(startTime)
            let bytesDelta = totalBytesWritten - previousBytesWritten
            let averageSpeed = Double(bytesDelta) / timeInterval / (1024.0 * 1024.0)
            
            self.startTime = now
            self.previousBytesWritten = totalBytesWritten
            continuation?.yield(.progress(currentBytes: totalBytesWritten, totalBytes: totalBytesExpectedToWrite, speed: averageSpeed))
            
        } else {
            self.startTime = now
            self.previousBytesWritten = totalBytesWritten
            continuation?.yield(.progress(currentBytes: totalBytesWritten, totalBytes: totalBytesExpectedToWrite, speed: 0))
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Download completed with error: \(error.localizedDescription)")
        } else {
            print("Download completed successfully.")
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let completion = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completion()
            }
        }
    }
}

