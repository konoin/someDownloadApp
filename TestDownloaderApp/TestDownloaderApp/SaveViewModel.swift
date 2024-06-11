//
//  SaveViewModel.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 11.06.24.
//

import Foundation
import Combine
import UIKit

final class SaveViewModel: ObservableObject {
    @Published var podcast: Podcast?
    @Published var historyItems: [History]
    
    private var cancellables = Set<AnyCancellable>()
    
    let dataService = PersistenceController.shared
    var downloadController: DownloadController
    
    init(downloadController: DownloadController, historyItems: [History]) {
        self.downloadController = downloadController
        self.historyItems = historyItems
        setupBindings()
    }
    
    private func setupBindings() {
        downloadController.$podcast
            .receive(on: DispatchQueue.main)
            .assign(to: &$podcast)
    }
    
    func saveDownloadState(episode: Episode) {
        if let history = historyItems.first(where: { $0.id == Int64(episode.id) }) {
            dataService.update(entity: history, downloaded: true)
        } else {
            dataService.create(title: episode.title, id: Int64(episode.id), downloaded: true, date: Date(), fileURL: generateFileURL(title: episode.title))
        }
    }
    
    func generateFileURL(title: String) -> URL {
        guard let folderPath = podcast?.directoryURL else { return URL(string: "")! }
        
        let sanitizedEpisodeName = title.replacingOccurrences(of: " ", with: "")
        let filePath = folderPath.appendingPathComponent("\(sanitizedEpisodeName).mp3").path
        
        return URL(string: filePath)!
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
                                dataService.update(entity: history, downloaded: false)
                            }
                        }
                    }
                } else {
                    print("Episode not marked for download: \(episode.title)")
                }
            }
        }
    }
    
    func openFilePicker() {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        documentPicker.delegate = UIApplication.shared.windows.first?.rootViewController as? UIDocumentPickerDelegate
        documentPicker.allowsMultipleSelection = false
        let casefileUrl = documentsUrl.appendingPathComponent("Casefile True Crime")
        documentPicker.directoryURL = casefileUrl
        
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(documentPicker, animated: true, completion: nil)
        }
    }
}
