//
//  Creator.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 20.08.24.
//

import Foundation

protocol Creator {
    func createPodcast(collectionId: Int, artistName: String, collectionName: String, artworkUrl600: String) -> Podcast
    func createEpisode(trackId: Int, trackName: String, collectionID: Int, releaseDate: String, episodeUrl: String, trackTimeMillis: Int) -> Episode
}

extension Creator {
    func createPodcast(collectionId: Int, artistName: String, collectionName: String, artworkUrl600: String) -> Podcast {
        return Podcast(id: collectionId, title: collectionName, artist: artistName, imageURL: URL(string: artworkUrl600)!)
    }
    
    func createEpisode(trackId: Int, trackName: String, collectionID: Int, releaseDate: String, episodeUrl: String, trackTimeMillis: Int) -> Episode {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let date = dateFormatter.date(from: releaseDate)!
        
        let duration: Duration = .milliseconds(trackTimeMillis)
        
        return Episode(id: trackId, podcastID: collectionID, duration: duration, title: trackName, date: date, url: URL(string: episodeUrl)!)
    }
}
