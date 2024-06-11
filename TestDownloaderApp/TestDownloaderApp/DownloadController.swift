//
//  DownloadController.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 11.06.24.
//

import Foundation

class DownloadController: ObservableObject {
    
    @Published private(set) var podcast: Podcast?

    @MainActor
    func fetchPodcast() async throws {
        let url = URL(string: "https://itunes.apple.com/lookup?id=998568017&media=podcast&entity=podcastEpisode&limit=10")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        podcast = try decoder.decode(Podcast.self, from: data)
    }
}

