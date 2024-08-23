//
//  MockDownloadManager.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 2.07.24.
//

import Foundation
import Combine
import SwiftUI
@testable import TestDownloaderApp

class MockDownloadManager: MainViewModelProtocol {
    var mockPodcast: Podcast?
    var mockEpisode: Episode?
    var mockDownloadSession: MockDownload!
    var didCallDownload = false
    var didCallAddEpisodeToQueue = false
    var didCallPauseDownload = false
    var didCallResumeDownload = false
    var didCallCheckFile = false
    var testDownloads: [URL: Download] = [:]
    var testDownloadQueue: [Episode] = []

    func fetchPodcast() async {
          let url = URL(string: "https://itunes.apple.com/lookup?id=998568017&media=podcast&entity=podcastEpisode&limit=10")!
          do {
              let (data, _) = try await URLSession.shared.data(from: url)
              let decoder = JSONDecoder()
              decoder.dateDecodingStrategy = .iso8601
              mockPodcast = try decoder.decode(Podcast.self, from: data)
          } catch {
              print("Error fetching podcast: \(error.localizedDescription)")
          }
      }
    
    func downloadEpisode(_ episode: Episode, downloadQueue: DownloadQueue) async {
        self.mockPodcast = Podcast.test
        guard testDownloads[episode.url] == nil else { return }
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.test.background")
        let downloadSession = URLSession(configuration: configuration, delegate: nil, delegateQueue: .main)
        let download = Download(url: episode.url, downloadSession: downloadSession)
        testDownloads[episode.url] = download
        mockPodcast?[episode.id]?.isDownloading = true
        mockPodcast?[episode.id]?.downloadState = .downloaded
        mockPodcast?[episode.id]?.downloadQueue = downloadQueue
    }
    
    func addEpisodeToQueue(_ episode: Episode, queue: DownloadQueue) {
        self.mockPodcast = Podcast.test
        testDownloadQueue.append(episode)
        
        if testDownloadQueue.contains(episode) {
            mockPodcast?[episode.id]?.downloadState = .inQueue
            mockPodcast?[episode.id]?.downloadQueue = queue
        }
        
    }
    
    func pauseDownload(for episode: Episode) {
        self.mockPodcast = Podcast.test
        mockPodcast?[episode.id]?.isDownloading = false
        mockPodcast?[episode.id]?.downloadState = .paused
    }
    
    func resumeDownload(for episode: Episode) {
        self.mockPodcast = Podcast.test
        mockPodcast?[episode.id]?.isDownloading = true
        mockPodcast?[episode.id]?.downloadState = .inProgress
    }

//    func updateHistoryItems(with items: FetchedResults<TestDownloaderApp.History>) {
//        print("123")
//    }
//    
//    func checkFile(historyItems: [TestDownloaderApp.History]) {
//        print("123")
//    }
}
