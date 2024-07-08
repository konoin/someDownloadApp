//
//  MockDownloadSession.swift
//  TestDownloaderAppTests
//
//  Created by Mikita Palyka on 20.06.24.
//

import Foundation

class MockDownloadSession {
    var events: [DownloadEvent] = []
    
    func startDownload(for url: URL) {
        events.append(.started)
    }
}

class MockDownload {
    let url: URL
    let downloadSession: URLSession
    var events: AsyncStream<DownloadEvent>

    init(url: URL, downloadSession: URLSession) {
        self.url = url
        self.downloadSession = downloadSession
        self.events = AsyncStream { continuation in            
            continuation.yield(.started)
            continuation.yield(.progress(0.5))
            continuation.yield(.completed)
            continuation.finish()
        }
    }
}

enum DownloadEvent {
    case started
    case progress(Double)
    case completed
    case failed(Error)
}
