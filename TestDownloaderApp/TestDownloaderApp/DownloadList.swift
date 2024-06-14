//
//  DownloadList.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 15.05.24.
//

import SwiftUI

struct DownloadList: View {
    
    @Binding var queueEpisodes: [Episode]
    @Binding var parallelEpisodes: [Episode]

    var body: some View {
        VStack {
            List {
                Section("queue") {
                    if queueEpisodes.isEmpty {
                        Text("queue is empty")
                    } else {
                        ForEach(queueEpisodes) { episode in
                            VStack(alignment: .leading) {
                                Text(episode.title)
                                ProgressView(value: episode.progress)
                            }
                            .padding()
                        }
                    }
                }
                Section("parallel") {
                    if parallelEpisodes.isEmpty {
                        Text("parallel is empty")
                    } else {
                        ForEach(parallelEpisodes) { episode in
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
