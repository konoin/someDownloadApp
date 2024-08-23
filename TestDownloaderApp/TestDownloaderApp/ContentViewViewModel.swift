//
//  ContentViewViewModel.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 13.05.24.
//

import SwiftData
import Combine
import SwiftUI

final class ContentViewViewModel: NSObject, ObservableObject, ContentViewViewModelProtocol {
    @Published var podcast: Podcast?
    @Published var testCompleted: Bool = false
    @Published var historyItems: [History] = []
    @Published var queueEpisodes: [Episode] = []
    @Published var parallelEpisodes: [Episode] = []

    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var dataService = HistoryService()
    
    private lazy var downloadManager: DownloadManager = {
        let manager = DownloadManager()
        manager.$podcast
            .receive(on: DispatchQueue.main)
            .assign(to: \.podcast, on: self)
            .store(in: &cancellables)
        manager.historyItems = self.historyItems

        return manager
    }()
}

//MARK: - DownlaodManager
extension ContentViewViewModel {
    @MainActor
    func fetchPodcast() async {
        podcast = try? await downloadManager.fetchPodcast()
    }
    
    @MainActor 
    func downloadEpisode(_ episode: Episode, downloadQueue: DownloadQueue) async {
        try? await downloadManager.download(episode, downloadQueue: downloadQueue)
    }
    
    @MainActor 
    func addEpisodeToQueue(_ episode: Episode, queue: DownloadQueue) {
        downloadManager.addEpisodeToQueue(episode, queue: queue)
    }
    
    func pauseDownload(for episode: Episode) {
        downloadManager.pauseDownload(for: episode)
    }
    
    func resumeDownload(for episode: Episode) {
        downloadManager.resumeDownload(for: episode)
    }
    
    func updateHistoryItems() {
        do {
            historyItems = try dataService.fetch()
            print("Successfully fetched history items.")
        } catch {
            print("Failed to fetch history items with error: \(error.localizedDescription)")
        }
    }
    
    func checkFile() {
        downloadManager.checkFile(historyItams: historyItems)
    }
}
