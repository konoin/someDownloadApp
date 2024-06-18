//
//  DownloadManager.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 13.06.24.
//

import Foundation

final class DownlaodManager: ObservableObject {
    @Published var podcast: Podcast?
    private var downloadSession: URLSession
    private var downloads: [URL: Download] = [:]
    private var downloadQueue: [Episode] = []
    private var isDownloading: Bool = false
    var historyItems: [History]?
    let dataService = PersistenceController.shared
    
    init() {
        let configuration = URLSessionConfiguration.default
        self.downloadSession = URLSession(configuration: configuration, delegate: nil, delegateQueue: .main)
    }
    
    @MainActor
    func fetchPodcast() async throws -> Podcast? {
        let url = URL(string: "https://itunes.apple.com/lookup?id=998568017&media=podcast&entity=podcastEpisode&limit=10")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        podcast = try decoder.decode(Podcast.self, from: data)
        if let items = historyItems {
            checkFile(historyItams: items)
        }
        return podcast
    }
    
    @MainActor
    func download(_ episode: Episode, downloadQueue: DownloadQueue) async throws {
        guard downloads[episode.url] == nil else { return }
        let download = Download(url: episode.url, downloadSession: downloadSession)
        downloads[episode.url] = download
        podcast?[episode.id]?.isDownloading = true
        podcast?[episode.id]?.downloadState = .sendRequest
        podcast?[episode.id]?.downloadQueue = downloadQueue
        for await event in download.events {
            process(event, for: episode)
        }
        
        downloads[episode.url] = nil
    }
    
    @MainActor
    func addEpisodeToQueue(_ episode: Episode, queue: DownloadQueue) {
        downloadQueue.append(episode)
        if downloadQueue.contains(episode) {
            podcast?[episode.id]?.downloadState = .inQueue
            podcast?[episode.id]?.downloadQueue = queue
        }
        processQueue(queue: queue)
    }
    
    
    @MainActor
    private func processQueue(queue: DownloadQueue) {
        guard !isDownloading, !downloadQueue.isEmpty else {
            return }
        
        isDownloading = true
        let episode = downloadQueue.removeFirst()
        
        Task {
            do {
                try await download(episode, downloadQueue: queue)
            } catch {
                print("Failed to download:", error.localizedDescription)
            }
            
            isDownloading = false
            processQueue(queue: queue)
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
            saveDownloadState(episode: episode)
            saveFile(for: episode, at: url)
        }
    }
    
    func saveFile(for episode: Episode, at url: URL) {
        guard let historyItems = historyItems else { return }
        
        for historyItem in historyItems {
            if historyItem.title == episode.title {
                dataService.update(entity: historyItem, title: episode.title, downloaded: true)
            }
        }
        
        podcast?[episode.id]?.downloadState = .downloaded
        guard let directoryURL = podcast?.directoryURL else { return }
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
                print("Directory created at: \(directoryURL)")
            } catch {
                print("Failed to create directory: \(error.localizedDescription)")
                return
            }
        }
        
        let sanitizedEpisodeName = episode.title.replacingOccurrences(of: " ", with: "")
        let fileURL = directoryURL.appendingPathComponent("\(sanitizedEpisodeName).mp3")
        do {
            try fileManager.moveItem(at: url, to: fileURL)
            print("File moved to: \(fileURL)")
        } catch {
            print("Failed to move file: \(error.localizedDescription)")
        }
        
    }
    
    func saveDownloadState(episode: Episode) {
        guard let historyItems = historyItems else { return }
        
        if let history = historyItems.first(where: { $0.id == Int64(episode.id) }) {
            dataService.update(entity: history, downloaded: true, fileURL: generateFileUrl(episode: episode))
        } else {
            dataService.create(title: episode.title, id: Int64(episode.id), downloaded: true, date: Date(), fileURL: generateFileUrl(episode: episode))
        }
    }
    
    func generateFileUrl(episode: Episode) -> String {
        guard let folderPath = podcast?.directoryURL else { return ""}
        let sanitizedEpisodeName = episode.title.replacingOccurrences(of: " ", with: "")
        let filePath = folderPath.appendingPathComponent("\(sanitizedEpisodeName).mp3").path
        return filePath
    }
    
    func checkFile(historyItams: [History]) {
        guard let testEpisodes = podcast?.episodes else { return }
        guard let folderPath = podcast?.directoryURL else { return }
//        guard let historyItems = historyItems else { return }
        
        for episode in testEpisodes {
            let sanitizedEpisodeName = episode.title.replacingOccurrences(of: " ", with: "")
            let filePath = folderPath.appendingPathComponent("\(sanitizedEpisodeName).mp3").path
            
            
            
            print("Checking file at path:", filePath)
            for historyItem in historyItams {
                if historyItem.title == episode.title && historyItem.downloaded {
                    if FileManager.default.fileExists(atPath: filePath) {
                        print("File exists for episode: \(episode.title)")
                    } else {
                        for history in historyItams {
                            if history.id == Int64(episode.id) {
                                podcast?[episode.id]?.downloadState = .idle
                                podcast?[episode.id]?.downloadQueue = .idle
                                dataService.update(entity: history, downloaded: false, fileURL: "deleted")
                            }
                        }
                    }
                } else {
                    print("Episode not marked for download: \(episode.title)")
                    podcast?[episode.id]?.downloadState = .idle
                    podcast?[episode.id]?.downloadQueue = .idle
                }
            }
        }
    }
}
