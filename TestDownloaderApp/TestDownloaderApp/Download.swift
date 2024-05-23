//
//  Download.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 15.05.24.
//

import Foundation

final class Download: NSObject {
    let url: URL
    let downloadSession: URLSession
    var resumeData: Data?
    
    private var continuation: AsyncStream<Event>.Continuation?
    
    private var checkContinuation: CheckedContinuation<(URL, URLSessionDownloadTask), Never>?
    private var previousBytesWritten: Int64 = 0
    private var totalBytesWritten: Int64 = 0
    private var startTime: Date?
    
    lazy var task: URLSessionDownloadTask = {
        let task = downloadSession.downloadTask(with: url)
        task.delegate = self
        
        return task
    }()
    
    init(url: URL, downloadSession: URLSession) {
        self.url = url
        self.downloadSession = downloadSession
    }
    
    lazy var downloadTestSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.test.download.session")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    var isDownloading: Bool {
        task.state == .running
    }
    
    var events: AsyncStream<Event> {
        AsyncStream { continuation in
            self.continuation = continuation
            self.task.resume()
            continuation.onTermination = { @Sendable [weak self] _ in
                self?.task.cancel()
            }
        }
    }
    
    func pause() {
        self.task.suspend()
    }
    
    func resume() {
        self.task.resume()
    }
}

extension Download {
    enum Event {
        case progress(currentBytes: Int64, totalBytes: Int64, speed: Double)
        case success(url: URL, downloadTask: URLSessionDownloadTask)
    }
}

extension Download: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        let fileManager = FileManager.default
        do {
            // Создаем URL для постоянного местоположения файла
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let destinationURL = documentsDirectory.appendingPathComponent(location.lastPathComponent)
            
            // Удаляем файл по этому URL, если он уже существует
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            
            // Перемещаем файл из временного местоположения в постоянное
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
            self.totalBytesWritten = totalBytesWritten
            let averageSpeed = Double(totalBytesWritten) / timeInterval / (1024.0 * 1024.0)
            
            self.startTime = now
            self.previousBytesWritten = totalBytesWritten
            continuation?.yield(.progress(currentBytes: totalBytesWritten, totalBytes: totalBytesExpectedToWrite, speed: averageSpeed))
            
        } else {
            self.startTime = now
            self.previousBytesWritten = totalBytesWritten
            continuation?.yield(.progress(currentBytes: totalBytesWritten, totalBytes: totalBytesExpectedToWrite, speed: 0))
        }
    }
}
