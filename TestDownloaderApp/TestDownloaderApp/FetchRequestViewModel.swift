//
//  FetchRequestViewModel.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 10.06.24.
//

import Foundation
import Combine

final class FetchRequestViewModel: ObservableObject {
    
    @Published var podcast: Podcast?
    
    var downloadController: DownloadController
    private var cancellables = Set<AnyCancellable>()
    
    init(downloadController: DownloadController) {
        self.downloadController = downloadController
        setupBindings()
    }
    
    private func setupBindings() {
        downloadController.$podcast
            .receive(on: DispatchQueue.main)
            .assign(to: &$podcast)
    }
    
    func fetchEpisodes() async {
        try? await downloadController.fetchPodcast()
    }
}

