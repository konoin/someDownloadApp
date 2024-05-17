//
//  MainViewModel.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 13.05.24.
//

import Foundation

final class MainViewModel: NSObject, ObservableObject {
    @Published var podcast: Podcast?
    @Published var downloads: [URL: Download] = [:]
    
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
        for await event in download.events {
            process(event, for: episode)
        }
        downloads[episode.url] = nil
    }
    
    func pauseDownload(for episode: Episode) {
        downloads[episode.url]?.pause()
        podcast?[episode.id]?.isDownloading = false
    }
    
    func resumeDownload(for episode: Episode) {
        downloads[episode.url]?.resume()
        podcast?[episode.id]?.isDownloading = true
    }
}
private extension MainViewModel {
    func process(_ event: Download.Event, for episode: Episode) {
        switch event {
        case let .progress(current, total, speed):
            podcast?[episode.id]?.update(currentBytes: current, totalBytes: total, speed: speed)
        case let .success(url):
            saveFile(for: episode, at: url)
        }
    }
    
    func saveFile(for episode: Episode, at url: URL) {
        
        do {
            let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let data = try Data(contentsOf: url)
            let fileURL = dir.appendingPathComponent("\(episode.title).mp3")
            try data.write(to: fileURL)

        } catch {
            print("Error saving file: \(error.localizedDescription)")
        }
    }
    
}

extension Podcast {
    var directoryURL: URL {
        URL.documentsDirectory
            .appending(path: "\(title)", directoryHint: .isDirectory)
    }
}

extension Episode {
    var fileURL: URL {
        URL.documentsDirectory
            .appending(path: "\(podcastID)")
            .appending(path: "\(id)")
            .appendingPathExtension("mp3")
    }
}


extension URL: Comparable {
    public static func < (lhs: URL, rhs: URL) -> Bool {
        return lhs.absoluteString < rhs.absoluteString
    }
}
