//
//  DownloadList.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 15.05.24.
//

import SwiftUI

struct DownloadList: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    
//    var queueEpisodes: [Episode]
    var parallelEpisodes: [Episode]
    
    var body: some View {
        VStack {
            List {
                Section("queue") {
                    if mainViewModel.queueEpisodes.isEmpty {
                        Text("queue is empty")
                    } else {
                        ForEach(mainViewModel.queueEpisodes) { episode in
                            VStack(alignment: .leading) {
                                Text(episode.title)
                                ProgressView(value: episode.progress)
                            }
                            .padding()
                        }
                    }
                }
                Section("parallel") {
                    if convertParallelEpisodes().isEmpty {
                        Text("parallel is empty")
                    } else {
                        ForEach(convertParallelEpisodes()) { episode in
                            VStack(alignment: .leading) {
                                Text(episode.title)
                                ProgressView(value: episode.progress)
                            }
                            .padding()
                        }
                    }
                }
            }
        }
    }
}

extension DownloadList {
    func convertParallelEpisodes() -> [Episode] {
        var newArray: [Episode] = []
        for parallelEpisode in self.parallelEpisodes {
            if ((mainViewModel.podcast?.episodes.contains(where: { $0.title == parallelEpisode.title })) != nil) {
                newArray.append(parallelEpisode)
            }
        }
        return newArray
    }
}
