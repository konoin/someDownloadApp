//
//  Episode.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 15.05.24.
//

import Foundation

struct Episode: Identifiable, Hashable {
    let id: Int
    let podcastID: Int
    let duration: Duration
    let title: String
    let date: Date
    let url: URL
    var isDownloading: Bool = false
    private(set) var currentBytes: Int64 = 0
    private(set) var totalBytes: Int64 = 0
    private(set) var speed: Double = 0.0
    var isSequentil: Bool = false

    var progress: Double {
        guard totalBytes > 0 else { return 0.0 }
        
        return Double(currentBytes) / Double(totalBytes)
    }

    mutating func update(currentBytes: Int64, totalBytes: Int64, speed: Double) {
        self.currentBytes = currentBytes
        self.totalBytes = totalBytes
        self.speed = speed
    }
    
    static func == (lhs: Episode, rhs: Episode) -> Bool {
         return lhs.id == rhs.id
     }

     func hash(into hasher: inout Hasher) {
         hasher.combine(id)
     }
}

extension Episode: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "trackId"
        case podcastID = "collectionId"
        case duration = "trackTimeMillis"
        case title = "trackName"
        case date = "releaseDate"
        case url = "episodeUrl"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.podcastID = try container.decode(Int.self, forKey: .podcastID)
        let duration = try container.decode(Int.self, forKey: .duration)
        self.duration = .milliseconds(duration)
        self.title = try container.decode(String.self, forKey: .title)
        self.date = try container.decode(Date.self, forKey: .date)
        self.url = try container.decode(URL.self, forKey: .url)
    }
}
