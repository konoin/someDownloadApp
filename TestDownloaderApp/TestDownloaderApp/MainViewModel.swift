//
//  MainViewModel.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 13.05.24.
//

import Foundation
import UIKit
import CoreData

final class MainViewModel: NSObject, ObservableObject {
    
    @Published var podcast: Podcast?
    @Published var downloads: [URL: Download] = [:]
    @Published var finishDownload: [Download: Bool] = [:]
    @Published var progress: [Episode: Double] = [:]
    @Published var dowloadParallelEpisode: [String: Bool] = [:]
    @Published var dowloadSequentialEpisode: [String: Bool] = [:]
    @Published var dowloadFinishedEpisode: [String: Bool] = [:]
    @Published var downloadQueue: [Episode] = []
    
    @Published var historyItems: [History]
    
    init(historyItems: [History]) {
        self.historyItems = historyItems
    }
    
    let dataService = PersistenceController.shared
    
    private var isDownloading: Bool = false
    private var data: Data?
    
    private lazy var downloadSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: .main)
    }()
    
    var urlSession: URLSession = URLSession(configuration: .default)
    
    @MainActor
    func fetchPodcast() async throws {
        let url = URL(string: "https://itunes.apple.com/lookup?id=998568017&media=podcast&entity=podcastEpisode&limit=10")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        podcast = try decoder.decode(Podcast.self, from: data)
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
}
private extension MainViewModel {
    func process(_ event: Download.Event, for episode: Episode) {
        switch event {
        case let .progress(current, total, speed):
            podcast?[episode.id]?.downloadState = .inProgress
            podcast?[episode.id]?.update(currentBytes: current, totalBytes: total, speed: speed)
            progress[episode] = Double(current) / Double(total)
        case let .success(url, _):
            saveDownloadState(episode: episode)
            saveFile(for: episode, at: url)
        }
    }
    
    func saveFile(for episode: Episode, at url: URL) {
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
}

extension Podcast {
    var directoryURL: URL {
        URL.documentsDirectory
            .appending(path: "\(title)", directoryHint: .isDirectory)
    }
}

extension URL: Comparable {
    public static func < (lhs: URL, rhs: URL) -> Bool {
        return lhs.absoluteString < rhs.absoluteString
    }
}

extension MainViewModel {
    func saveDownloadState(episode: Episode) {
        if let history = historyItems.first(where: { $0.id == Int64(episode.id) }) {
            dataService.update(entity: history, downloaded: true)
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
    
    func checkFile() {
        guard let testEpisodes = podcast?.episodes else { return }
        guard let folderPath = podcast?.directoryURL else { return }
        
        for episode in testEpisodes {
            let sanitizedEpisodeName = episode.title.replacingOccurrences(of: " ", with: "")
            let filePath = folderPath.appendingPathComponent("\(sanitizedEpisodeName).mp3").path
            
            
            
            print("Checking file at path:", filePath)
            for historyItem in self.historyItems {
                if historyItem.title == episode.title && historyItem.downloaded {
                    if FileManager.default.fileExists(atPath: filePath) {
                        print("File exists for episode: \(episode.title)")
                    } else {
                        for history in historyItems {
                            if history.id == Int64(episode.id) {
                                dataService.update(entity: history, downloaded: false, fileURL: "deleted")
                            }
                        }
                    }
                } else {
                    print("Episode not marked for download: \(episode.title)")
                }
            }
        }
    }
    
    func openFilePicker() {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        documentPicker.delegate = UIApplication.shared.windows.first?.rootViewController as? UIDocumentPickerDelegate
        documentPicker.allowsMultipleSelection = false
        let casefileUrl = documentsUrl.appendingPathComponent("Casefile True Crime")
        documentPicker.directoryURL = casefileUrl
        
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(documentPicker, animated: true, completion: nil)
        }
    }
}
