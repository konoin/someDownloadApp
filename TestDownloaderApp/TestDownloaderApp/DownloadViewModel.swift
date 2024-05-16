//
//  DownloadViewModel.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 15.05.24.
//

import Foundation

final class DownloadViewModel: ObservableObject {
    @Published var downloadEpisodes: [Episode] = []
    
    func addDownload(downloadEpisodes: Episode) {
        self.downloadEpisodes.append(downloadEpisodes)
    }
    
    func deleteSuccessDownloadEpisodes(successEpisode: Episode) {
        if let index = downloadEpisodes.firstIndex(where: { $0.id == successEpisode.id }) {
            downloadEpisodes.remove(at: index)
        }
    }
}
