//
//  MainViewModel.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 13.05.24.
//

import CoreData
import Combine
import SwiftUI

final class MainViewModel: NSObject, ObservableObject {
    @Published var podcast: Podcast?
    @Published var historyItems: [History] = []
    @Published var queueEpisodes: [Episode] = []
    @Published var parallelEpisodes: [Episode] = []

    
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var downloadManager: DownlaodManager = {
        let manager = DownlaodManager()
        manager.$podcast
            .receive(on: DispatchQueue.main)
            .assign(to: \.podcast, on: self)
            .store(in: &cancellables)
        manager.historyItems = self.historyItems

        return manager
    }()
}

//MARK: - DownlaodManager
extension MainViewModel {
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
    
    func updateHistoryItems(with items: FetchedResults<History>) {
        self.historyItems = Array(items)
    }
    
    func checkFile(historyItems: [History]) {
        downloadManager.checkFile(historyItams: historyItems)
    }
}
