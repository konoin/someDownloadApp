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
    @State private var selectedEpisodes: Set<Episode> = []
    @State var queueEpisodes: [Episode] = []
    @State var parallelEpisodes: [Episode] = []
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Header(podcast: viewModel.podcast)
                    if let podcast = viewModel.podcast {
                        ForEach(podcast.episodes) { episode in
                            EpisodeRow(
                                viewModel: viewModel, episode: episode,
                                downloadButtonPressed: { toggleDownload(for: episode) },
                                addToQueueButtonPressed: { addToQueue(episode) }
                            )
                            .background(selectedEpisodes.contains(episode) ? Color.gray.opacity(0.2) : Color.clear)
                            .onTapGesture {
                                toggleSelection(for: episode)
                            }
                        }
                    } else {
                        ForEach(0..<10) { _ in
                            EpisodeRow(viewModel: viewModel, episode: nil, downloadButtonPressed: {
                            }, addToQueueButtonPressed: {})
                        }
                    }
                }
                .listStyle(.plain)
                .task {
                    try? await viewModel.fetchPodcast()
                }
                .onAppear {
                    viewModel.downloadUserDefaults()
                }
                NavigationLink(destination: DownloadList(queueEpisodes: $queueEpisodes, parallelEpisodes: $parallelEpisodes, progress: viewModel.progress)) {
                    Image(systemName: "arrow.down.circle")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
            }
        }
    }
    
    private func toggleSelection(for episode: Episode) {
          if selectedEpisodes.contains(episode) {
              selectedEpisodes.remove(episode)
          } else {
              selectedEpisodes.insert(episode)
          }
      }

      private func addToQueue(_ episode: Episode) {
          viewModel.addEpisodeToQueue(episode)
          queueEpisodes.append(episode)
      }

      private func addSelectedEpisodesToQueue() {
          for episode in selectedEpisodes {
              viewModel.addEpisodeToQueue(episode)
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
