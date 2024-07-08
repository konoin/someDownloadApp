//
//  MainViewModelProtocol.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 7.07.24.
//

import Foundation
import SwiftUI

protocol MainViewModelProtocol {
    @MainActor
    func fetchPodcast() async
    
    @MainActor
    func downloadEpisode(_ episode: Episode, downloadQueue: DownloadQueue) async
    
    @MainActor
    func addEpisodeToQueue(_ episode: Episode, queue: DownloadQueue)
    
    func pauseDownload(for episode: Episode)
    
    func resumeDownload(for episode: Episode)
//    
//    func updateHistoryItems(with items: FetchedResults<History>)
//    
//    func checkFile(historyItems: [History])
}
