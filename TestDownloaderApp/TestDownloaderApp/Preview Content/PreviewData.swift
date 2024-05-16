//
//  PreviewData.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 15.05.24.
//

import Foundation

extension Podcast {
    static var preview: Podcast {
        let url = Bundle.main.url(forResource: "JSON", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try! decoder.decode(Podcast.self, from: data)
    }
}

extension [Episode] {
    static var preview: [Episode] {
        Podcast.preview.episodes
    }
}

extension Episode {
    static var preview: Episode {
        var episode = [Episode].preview[0]
        episode.update(currentBytes: 90, totalBytes: 100)
        return episode
    }
}
