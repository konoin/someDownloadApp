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
    
    var progress: [Episode: Double] = [:]
    
    var body: some View {
        VStack {
            List {
                Section("queue") {
                    ForEach(queueEpisodes) { episode in
                        VStack(alignment: .leading) {
                            Text(episode.title)
                            ProgressView(value: progress[episode])
                        }
                        .padding()
                    }
                }
                Section("parallel") {
                    ForEach(parallelEpisodes) { episode in
                        VStack(alignment: .leading) {
                            Text(episode.title)
                            ProgressView(value: progress[episode])
                        }
                        .padding()
                    }
                }
            }
        }
    }
}

//#Preview {
//    DownloadList()
//}
