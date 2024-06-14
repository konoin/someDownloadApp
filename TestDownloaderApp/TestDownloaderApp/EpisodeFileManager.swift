//
//  EpisodeFileManager.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 13.06.24.
//

import Foundation

final class EpisodeFileManager: ObservableObject {
    var historyItems: [History]
    var podcast: Podcast?
    
    let dataService = PersistenceController.shared
    
    init(historyItems: [History], podcast: Podcast? = nil) {
        self.historyItems = historyItems
        self.podcast = podcast
    }
    
    func saveFile(for episode: Episode, at url: URL) {
        for historyItem in historyItems {
            if historyItem.title == episode.title {
                dataService.update(entity: historyItem, title: episode.title, downloaded: true)
            }
        }
        
        podcast?[episode.id]?.downloadState = .downloaded
        guard let directoryURL = podcast?.directoryURL else { return }
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
                print("Directory created at: \(directoryURL)")
            } catch {
                print("Failed to create directory: \(error.localizedDescription)")
                return
            }
        }
        
        let sanitizedEpisodeName = episode.title.replacingOccurrences(of: " ", with: "")
        let fileURL = directoryURL.appendingPathComponent("\(sanitizedEpisodeName).mp3")
        do {
            try fileManager.moveItem(at: url, to: fileURL)
            print("File moved to: \(fileURL)")
        } catch {
            print("Failed to move file: \(error.localizedDescription)")
        }
        
    }
    
    func saveDownloadState(episode: Episode) {
        if let history = historyItems.first(where: { $0.id == Int64(episode.id) }) {
            dataService.update(entity: history, downloaded: true)
        } else {
            dataService.create(title: episode.title, id: Int64(episode.id), downloaded: true, date: Date(), fileURL: generateFileUrl(episode: episode))
        }
    }
    
    func generateFileUrl(episode: Episode) -> String {
        guard let folderPath = podcast?.directoryURL else { return ""}
        let sanitizedEpisodeName = episode.title.replacingOccurrences(of: " ", with: "")
        let filePath = folderPath.appendingPathComponent("\(sanitizedEpisodeName).mp3").path
        return filePath
    }
    
    func checkFile() {
        guard let testEpisodes = podcast?.episodes else { return }
        guard let folderPath = podcast?.directoryURL else { return }
        
        for episode in testEpisodes {
            let sanitizedEpisodeName = episode.title.replacingOccurrences(of: " ", with: "")
            let filePath = folderPath.appendingPathComponent("\(sanitizedEpisodeName).mp3").path
            
            
            
            print("Checking file at path:", filePath)
            for historyItem in self.historyItems {
                if historyItem.title == episode.title && historyItem.downloaded {
                    if FileManager.default.fileExists(atPath: filePath) {
                        print("File exists for episode: \(episode.title)")
                    } else {
                        for history in historyItems {
                            if history.id == Int64(episode.id) {
                                dataService.update(entity: history, downloaded: false, fileURL: "deleted")
                            }
                        }
                    }
                } else {
                    print("Episode not marked for download: \(episode.title)")
                }
            }
        }
    }
}
