//
//  ContentView.swift
//  TestDownloaderApp
//
//  Created by Mikita Palyka on 13.05.24.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject var viewModel = MainViewModel()
    @StateObject var downloadViewModel = DownloadViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Header(podcast: viewModel.podcast)
                    if let podcast = viewModel.podcast {
                        ForEach(podcast.episodes) { episode in
                            EpisodeRow(episode: episode, viewModel: downloadViewModel) {
                                toggleDownload(for: episode)
                                viewModel.testEpisode.append(episode)
                                downloadViewModel.addDownload(downloadEpisodes: episode)
                            }
                        }
                    } else {
                        ForEach(0..<10) { _ in
                            EpisodeRow(episode: nil, viewModel: downloadViewModel, downloadButtonPressed: {
                                print("some test")
                            })
                        }
                    }
                }
                .listStyle(.plain)
                .task {
                    try? await viewModel.fetchPodcast()
                }
                NavigationLink(destination: DownloadList(downloadViewModel: viewModel)) {
                    Image(systemName: "arrow.down.circle")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
            }
        }
    }
}

private extension ContentView {
    func toggleDownload(for episode: Episode) {
        if episode.isDownloading {
            viewModel.pauseDownload(for: episode)
        } else {
            if episode.progress > 0 {
                viewModel.resumeDownload(for: episode)
            } else {
                Task { try? await viewModel.download(episode) }
            }
        }
    }
}

#Preview {
    ContentView()
}
