//
//  DownloadManager.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 13.06.24.
//

import Foundation
import Combine

final class DownlaodManager: ObservableObject {
    @Published var podcast: Podcast?
    private var downloadSession: URLSession
    private var downloads: [URL: Download] = [:]
    private var downloadQueue: [Episode] = []
    private var isDownloading: Bool = false
    private var cancellables: Set<AnyCancellable> = []
    
    var historyItems: [History]
    var episodeFileManager: EpisodeFileManager?
    
    init(podcast: Published<Podcast?>.Publisher, historyItems: [History]) {
        self.historyItems = historyItems
        let configuration = URLSessionConfiguration.default
        self.downloadSession = URLSession(configuration: configuration, delegate: nil, delegateQueue: .main)
        
        podcast
            .receive(on: DispatchQueue.main)
            .assign(to: \.podcast, on: self)
            .store(in: &cancellables)
        self.episodeFileManager = EpisodeFileManager(historyItems: historyItems, podcast: self.podcast)
    }
    
    @MainActor
    func fetchPodcast() async throws -> Podcast? {
        let url = URL(string: "https://itunes.apple.com/lookup?id=998568017&media=podcast&entity=podcastEpisode&limit=10")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        podcast = try decoder.decode(Podcast.self, from: data)
        
        return podcast
    }
    
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
        case let .success(url, _):
            episodeFileManager?.saveDownloadState(episode: episode)
            episodeFileManager?.saveFile(for: episode, at: url)
        }
    }
    
}
