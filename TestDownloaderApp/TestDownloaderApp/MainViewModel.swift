//
//  MainViewModel.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 13.05.24.
//

import CoreData
import Combine

final class MainViewModel: NSObject, ObservableObject {
    @Published var podcast: Podcast?
    @Published var historyItems: [History]
    
    private var fileManagerPickerManager: FilePickerManager
    
    private lazy var downloadManager: DownlaodManager = {
        let manager = DownlaodManager(podcast: $podcast, historyItems: historyItems)
        manager.$podcast
            .receive(on: DispatchQueue.main)
            .assign(to: \.podcast, on: self)
            .store(in: &cancellables)
        return manager
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(historyItems: [History]) {
        self.historyItems = historyItems
        self.fileManagerPickerManager = FilePickerManager()
        
        super.init()
        
        _ = self.downloadManager
    }
}

//MARK: -DownlaodManager
extension MainViewModel {
    @MainActor
    func fetchPodcast() async {
        podcast = try? await downloadManager.fetchPodcast()
    }
    
    @MainActor func downloadEpisode(_ episode: Episode) async {
        try? await downloadManager.download(episode)
    }
    
    @MainActor func addEpisodeToQueue(_ episode: Episode) {
        downloadManager.addEpisodeToQueue(episode)
    }
    
    func pauseDownload(for episode: Episode) {
        downloadManager.pauseDownload(for: episode)
    }
    
    func resumeDownload(for episode: Episode) {
        downloadManager.resumeDownload(for: episode)
    }
}

//MARK: -EpisodeFileManager
extension MainViewModel {
    func checkFile() {
        downloadManager.episodeFileManager?.checkFile()
    }
}

//MARK: -FileManagerPicker
extension MainViewModel {
    func openFilePicker() {
        fileManagerPickerManager.openFilePicker()
    }
}
