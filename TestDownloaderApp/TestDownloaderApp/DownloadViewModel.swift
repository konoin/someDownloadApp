//
//  DownloadViewModel.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 11.06.24.
//

import Foundation

class DownloadViewModel: ObservableObject {
    
    @Published var podcast: Podcast?
    @Published var downloads: [URL: Download] = [:]
    @Published var progress: [Episode: Double] = [:]
    
    private var downloadQueue: [Episode] = []
    private var isDownloading: Bool = false
    
    private lazy var downloadSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: .main)
    }()
    
    
    @MainActor
    func download(_ episode: Episode) async throws {
        guard downloads[episode.url] == nil else { return }
        let download = Download(url: episode.url, downloadSession: downloadSession)
        downloads[episode.url] = download
        podcast?[episode.id]?.isDownloading = true
        podcast?[episode.id]?.downloadState = .sendRequest
        for await event in download.events {
            process(event, for: episode)
        }
        
        downloads[episode.url] = nil
    }
    
    @MainActor
    func addEpisodeToQueue(_ episode: Episode) {
        downloadQueue.append(episode)
        if downloadQueue.contains(episode) {
            podcast?[episode.id]?.downloadState = .inQueue
        }
        processQueue()
    }
    
    @MainActor
    private func processQueue() {
        guard !isDownloading, !downloadQueue.isEmpty else {
            return }
        
        isDownloading = true
        let episode = downloadQueue.removeFirst()
        
        Task {
            do {
                try await download(episode)
            } catch {
                print("Failed to download:", error.localizedDescription)
            }
            
            isDownloading = false
            processQueue()
        }
    }
    
    func pauseDownload(for episode: Episode) {
        downloads[episode.url]?.pause()
        podcast?[episode.id]?.isDownloading = false
        podcast?[episode.id]?.downloadState = .paused
    }
    
    func resumeDownload(for episode: Episode) {
        downloads[episode.url]?.resume()
        podcast?[episode.id]?.isDownloading = true
        podcast?[episode.id]?.downloadState = .inProgress
    }
    
    func process(_ event: Download.Event, for episode: Episode) {
        switch event {
        case let .progress(current, total, speed):
            podcast?[episode.id]?.downloadState = .inProgress
            podcast?[episode.id]?.update(currentBytes: current, totalBytes: total, speed: speed)
            progress[episode] = Double(current) / Double(total)
        case let .success(url, _):
            print("is working")
//            saveDownloadState(episode: episode)
//            saveFile(for: episode, at: url)
        }
    }
    
}
